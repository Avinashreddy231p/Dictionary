import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../data/models/settings_state.dart';
import 'gemini_service.dart';
import 'on_device_ai_service.dart';

final onDeviceAiServiceProvider = Provider<OnDeviceAiService>((ref) {
  return OnDeviceAiService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  final settings = ref.watch(settingsProvider);
  final onDeviceAi = ref.watch(onDeviceAiServiceProvider);
  final geminiAi = ref.watch(geminiServiceProvider);
  return AiService(
    settings: settings,
    onDeviceAi: onDeviceAi,
    geminiAi: geminiAi,
  );
});

class AiService {
  final SettingsState settings;
  final OnDeviceAiService onDeviceAi;
  final GeminiService geminiAi;

  AiService({
    required this.settings,
    required this.onDeviceAi,
    required this.geminiAi,
  });

  /// Unified stream content generator following the 3-Tier Hybrid strategy
  Stream<String> streamExplanation(String prompt, {int maxOutputTokens = 1000}) async* {
    final mode = settings.aiProviderMode;

    if (mode == 'on_device') {
      final isReady = await onDeviceAi.isModelReady(settings.onDeviceModel);
      if (isReady) {
        yield* onDeviceAi.streamExplanation(prompt, settings.onDeviceModel, maxOutputTokens: maxOutputTokens);
      } else {
        yield 'Active local model is not downloaded. Please download it in AI Settings.';
      }
      return;
    }

    if (mode == 'hybrid_auto') {
      final isReady = await onDeviceAi.isModelReady(settings.onDeviceModel);
      if (isReady) {
        yield* onDeviceAi.streamExplanation(prompt, settings.onDeviceModel, maxOutputTokens: maxOutputTokens);
        return;
      }
      // Fallback to Cloud Gemini if on-device model is not installed/ready
      if (settings.geminiApiKey.isNotEmpty) {
        yield* geminiAi.streamContent(
          prompt,
          apiKey: settings.geminiApiKey,
          model: settings.geminiModel,
        );
        return;
      }
      yield* onDeviceAi.streamExplanation(prompt, settings.onDeviceModel, maxOutputTokens: maxOutputTokens);
      return;
    }

    // Cloud Gemini mode
    if (settings.geminiApiKey.isEmpty) {
      yield 'Please enter a valid Google Gemini API Key in Settings or switch to On-Device AI.';
      return;
    }
    yield* geminiAi.streamContent(
      prompt,
      apiKey: settings.geminiApiKey,
      model: settings.geminiModel,
    );
  }

  /// Check if an AI engine (On-Device or Cloud Gemini) is available
  Future<bool> isAiAvailable() async {
    if (!settings.geminiAiEnabled) return false;
    if (settings.aiProviderMode == 'on_device') {
      return await onDeviceAi.isModelReady(settings.onDeviceModel);
    }
    if (settings.aiProviderMode == 'hybrid_auto') {
      final isReady = await onDeviceAi.isModelReady(settings.onDeviceModel);
      if (isReady) return true;
      return settings.geminiApiKey.isNotEmpty;
    }
    return settings.geminiApiKey.isNotEmpty;
  }

  Stream<String> streamMnemonic(String word, String meaning) {
    const lang = 'English';
    final prompt = lang == 'Telgish'
        ? 'Write a mnemonic for the English word "$word" ($meaning). Use Telugu words spelled out in English letters (Manglish / Telgish, e.g., "idi gurthu pettukovadaniki easy ga untundi"). Do not use IPA symbols or Telugu script.'
        : lang != 'English'
            ? 'Write a mnemonic for the English word "$word" ($meaning). YOU MUST WRITE THE ENTIRE RESPONSE STRICTLY IN THE NATIVE $lang SCRIPT (no English). Max 2 sentences.'
            : 'Create a memorable, clever, and concise mnemonic device to help remember the word "$word" which means "$meaning". Keep it under 3 sentences.';
    return streamExplanation(prompt);
  }

  Stream<String> streamExplainNuance(String word, String partOfSpeech, String meaning) {
    const lang = 'English';
    final prompt = lang == 'Telgish'
        ? 'Explain the nuance of the $partOfSpeech "$word" ($meaning) using Telugu words spelled out in English letters (Manglish / Telgish style). Do not use IPA symbols or Telugu script.'
        : lang != 'English'
            ? 'Explain the nuance of the $partOfSpeech "$word" ($meaning). YOU MUST WRITE THE ENTIRE RESPONSE STRICTLY IN THE NATIVE $lang SCRIPT.'
            : 'Explain the subtle nuance, emotional tone, and usage context of the $partOfSpeech "$word" ($meaning) compared to common synonyms. Keep it clear, concise, and educational (2-3 short paragraphs max).';
    return streamExplanation(prompt);
  }

  Stream<String> streamContextExamples(String word, String partOfSpeech) {
    const lang = 'English';
    final prompt = lang == 'Telgish'
        ? 'Provide 3 example sentences using the $partOfSpeech "$word". Write the sentences in Telugu words spelled out using English letters (Manglish / Telgish style, e.g. "Nenu office ki reluctant ga vellanu"). Do not use IPA or Telugu script.'
        : lang != 'English'
            ? 'Provide 3 example sentences using the $partOfSpeech "$word". YOU MUST WRITE EVERY SENTENCE STRICTLY IN THE NATIVE $lang SCRIPT.'
            : 'Provide 3 distinct, practical example sentences using the $partOfSpeech "$word" in: 1) Casual conversation, 2) Professional/workplace setting, 3) Literature/journalism. Number each example clearly.';
    return streamExplanation(prompt);
  }

  Stream<String> streamCustomPrompt(String word, String promptType) {
    const lang = 'English';

    String coreTask = switch (promptType) {
      'simple' => 'Explain the meaning of the word "$word" in extremely simple, everyday words.',
      'story' => 'Write a short, engaging micro-story or real-life scenario that vividly illustrates the meaning of the word "$word".',
      'synonyms' => 'List the top synonyms of the word "$word" and explain their tone and subtle differences.',
      'etymology' => 'Explain the fascinating historical origin and root etymology of the word "$word".',
      _ => 'Provide an insightful analysis for the word "$word" focusing on $promptType.',
    };

    final prompt = lang == 'Telgish'
        ? '$coreTask Write the entire response in Telgish (Telugu words spelled out phonetically using English/Latin letters, e.g. Manglish). Do not use Telugu script or IPA symbols.'
        : lang != 'English'
            ? '$coreTask YOU MUST WRITE THE ENTIRE RESPONSE STRICTLY IN THE NATIVE $lang SCRIPT (using only native $lang characters, no English).'
            : coreTask;

    return streamExplanation(prompt);
  }

  /// Rate word difficulty (CEFR) instantly
  Future<String> getWordCefrRating(String word) async {
    if (settings.aiProviderMode != 'cloud_gemini') {
      final isReady = await onDeviceAi.isModelReady(settings.onDeviceModel);
      if (isReady) {
        return await onDeviceAi.rateWordDifficulty(word);
      }
    }
    return 'B2';
  }

  /// Stream AI-powered quiz questions & situational context challenges
  Stream<String> streamAiQuizQuestions(List<String> words) {
    final wordListStr = words.join(', ');
    final prompt = 'Generate 3 challenging multiple-choice quiz questions based on the following vocabulary words: [$wordListStr]. '
        'For each question, provide: 1) The question text (e.g., situational context or definition), 2) Four options (A, B, C, D), and 3) The correct answer clearly indicated. Make it educational and engaging.';
    return streamExplanation(prompt, maxOutputTokens: 1200);
  }

  /// Stream AI Etymology and Root-Word Graph historical evolution
  Stream<String> streamEtymologyGraph(String word) {
    final prompt = 'Provide an in-depth etymological breakdown and root-word family tree for the word "$word". '
        'Include: 1) Historical origin (Proto-Indo-European / Greek / Latin / Old French roots), '
        '2) Evolution timeline, and 3) Related English word family sharing the same root with their meanings. Format with clear headings.';
    return streamExplanation(prompt, maxOutputTokens: 1500);
  }

  /// Stream AI analysis and vocabulary extraction for pasted text excerpt
  Stream<String> streamExcerptAnalysis(String text) {
    final prompt = 'Analyze the following text excerpt thoroughly. Provide: 1) A concise 2-sentence summary of the core message, and 2) A curated list of 5-8 advanced vocabulary words, idioms, or technical terms found in the text along with their definitions and CEFR difficulty ratings. Text: "$text"';
    return streamExplanation(prompt, maxOutputTokens: 1500);
  }

  /// Stream AI Sentence Coach & Grammar Evaluation ("Write & Correct")
  Stream<String> streamSentenceEvaluation(String word, String userSentence) {
    final prompt = 'Evaluate the following sentence written by a student practicing the English vocabulary word "$word". '
        'Student Sentence: "$userSentence"\n\n'
        'Provide: 1) Encouraging critique on whether the word is used correctly in context, '
        '2) Grammar and phrasing corrections if any, and 3) A polished, exemplary version of the sentence. Keep it constructive and educational.';
    return streamExplanation(prompt, maxOutputTokens: 1000);
  }

  /// Stream AI Custom Context Story Generator for vocabulary collections
  Stream<String> streamCollectionStory(List<String> words, String genre) {
    final wordList = words.join(', ');
    final prompt = 'Write an engaging, cohesive short story in the genre of "$genre" that naturally incorporates all of the following vocabulary words: [$wordList]. '
        'Highlight or bold each vocabulary word when it appears in the story. Ensure the narrative is creative, natural, and approximately 2-3 paragraphs long.';
    return streamExplanation(prompt, maxOutputTokens: 2000);
  }
}
