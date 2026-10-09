import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiTestResult {
  final bool success;
  final String? errorMessage;
  final String? workingModel;

  GeminiTestResult({
    required this.success,
    this.errorMessage,
    this.workingModel,
  });
}

class GeminiModelInfo {
  final String id;
  final String name;
  final String description;

  GeminiModelInfo({
    required this.id,
    required this.name,
    required this.description,
  });
}

class GeminiService {
  final String defaultModel;

  GeminiService({this.defaultModel = 'gemini-2.0-flash'});

  String _cleanKey(String key) {
    return key
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", "")
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll('\t', '');
  }

  /// Dynamically extracts all available Gemini models supporting generateContent directly from Google's API.
  Future<List<GeminiModelInfo>> fetchAvailableModels({String? apiKey}) async {
    final cleanKey = apiKey != null ? _cleanKey(apiKey) : '';
    if (cleanKey.isEmpty) {
      return getDefaultModels();
    }

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$cleanKey');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': cleanKey,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawModels = data['models'] as List?;
        if (rawModels != null && rawModels.isNotEmpty) {
          final List<GeminiModelInfo> parsed = [];

          for (final m in rawModels) {
            final nameStr = (m['name'] as String? ?? '').replaceFirst('models/', '');
            final methods = (m['supportedGenerationMethods'] as List?)?.cast<String>() ?? [];

            if (methods.contains('generateContent') && nameStr.contains('gemini')) {
              final displayName = m['displayName'] as String? ?? _formatModelName(nameStr);
              final desc = m['description'] as String? ?? 'Google Gemini AI model';

              parsed.add(GeminiModelInfo(
                id: nameStr,
                name: displayName,
                description: desc,
              ));
            }
          }

          if (parsed.isNotEmpty) {
            parsed.sort((a, b) {
              if (a.id.contains('2.0') && !b.id.contains('2.0')) return -1;
              if (!a.id.contains('2.0') && b.id.contains('2.0')) return 1;
              return a.id.compareTo(b.id);
            });
            return parsed;
          }
        }
      }
    } catch (_) {}

    return getDefaultModels();
  }

  List<GeminiModelInfo> getDefaultModels() {
    return [
      GeminiModelInfo(
        id: 'gemini-2.0-flash',
        name: 'Gemini 2.0 Flash',
        description: 'Recommended • Next-gen speed & intelligence',
      ),
      GeminiModelInfo(
        id: 'gemini-1.5-flash',
        name: 'Gemini 1.5 Flash',
        description: 'Fast & lightweight for daily lookups',
      ),
      GeminiModelInfo(
        id: 'gemini-1.5-pro-latest',
        name: 'Gemini 1.5 Pro',
        description: 'Deep reasoning & complex nuance analysis',
      ),
    ];
  }

  String _formatModelName(String modelId) {
    return modelId
        .split('-')
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
        .join(' ');
  }

  /// Extracts models dynamically from the Google API for a given API key.
  Future<List<String>> _getModelsToTryDynamic(String apiKey, String? selectedModel) async {
    final cleanKey = _cleanKey(apiKey);
    final List<String> models = [];

    if (selectedModel != null && selectedModel.trim().isNotEmpty) {
      models.add(selectedModel.trim());
    }

    if (cleanKey.isNotEmpty) {
      try {
        final fetched = await fetchAvailableModels(apiKey: cleanKey);
        for (final m in fetched) {
          if (!models.contains(m.id)) {
            models.add(m.id);
          }
        }
      } catch (_) {}
    }

    // Dynamic fallbacks if offline or initial list empty
    final fallbackList = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro-latest', 'gemini-2.0-flash-lite'];
    for (final m in fallbackList) {
      if (!models.contains(m)) {
        models.add(m);
      }
    }

    return models;
  }

  Future<GeminiTestResult> testApiKey(String apiKey, {String? model}) async {
    final cleanKey = _cleanKey(apiKey);
    if (cleanKey.isEmpty) {
      return GeminiTestResult(
        success: false,
        errorMessage: 'API Key is empty. Please enter a valid Gemini API Key.',
      );
    }

    final modelsToTry = await _getModelsToTryDynamic(cleanKey, model);
    String lastError = 'Failed to connect to Gemini API.';

    for (final targetModel in modelsToTry) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent?key=$cleanKey',
      );

      try {
        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': cleanKey,
              },
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': 'Hello'}
                    ]
                  }
                ]
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          return GeminiTestResult(success: true, workingModel: targetModel);
        }

        String errorMsg;
        try {
          final body = jsonDecode(response.body);
          errorMsg = body['error']?['message'] ?? 'HTTP ${response.statusCode}';
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: ${response.reasonPhrase ?? response.body}';
        }

        if (response.statusCode == 400 || response.statusCode == 404) {
          lastError = errorMsg;
          continue;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          return GeminiTestResult(
            success: false,
            errorMessage: 'Invalid or restricted API Key ($errorMsg). Please verify your Google AI Studio key.',
          );
        } else if (response.statusCode == 429) {
          return GeminiTestResult(
            success: false,
            errorMessage: 'API Key rate limit / quota exceeded ($errorMsg).',
          );
        } else {
          lastError = errorMsg;
        }
      } on TimeoutException {
        lastError = 'Connection timed out. Please check your network connection.';
      } on SocketException {
        lastError = 'Network error. Please check your internet connection.';
      } catch (e) {
        lastError = e.toString().replaceAll('Exception: ', '');
      }
    }

    return GeminiTestResult(success: false, errorMessage: lastError);
  }

  Future<String> generateMnemonic(
    String word,
    String meaning, {
    required String apiKey,
    String? model,
  }) async {
    final prompt =
        'Create a memorable, clever, and concise mnemonic device to help remember the word "$word" which means "$meaning". Keep it under 3 sentences.';
    return _generateContent(prompt, apiKey: apiKey, model: model);
  }

  Future<String> explainNuance(
    String word,
    String partOfSpeech,
    String meaning, {
    required String apiKey,
    String? model,
  }) async {
    final prompt =
        'Explain the subtle nuance, emotional tone, and usage context of the $partOfSpeech "$word" ($meaning) compared to common synonyms. Keep it clear, concise, and educational (2-3 short paragraphs max).';
    return _generateContent(prompt, apiKey: apiKey, model: model);
  }

  Future<String> generateContextExamples(
    String word,
    String partOfSpeech, {
    required String apiKey,
    String? model,
  }) async {
    final prompt =
        'Provide 3 distinct, practical example sentences using the $partOfSpeech "$word" in: 1) Casual conversation, 2) Professional/workplace setting, 3) Literature/journalism. Number each example clearly.';
    return _generateContent(prompt, apiKey: apiKey, model: model);
  }

  Stream<String> streamMnemonic(
    String word,
    String meaning, {
    required String apiKey,
    String? model,
  }) {
    final prompt =
        'Create a memorable, clever, and concise mnemonic device to help remember the word "$word" which means "$meaning". Keep it under 3 sentences.';
    return streamContent(prompt, apiKey: apiKey, model: model);
  }

  Stream<String> streamExplainNuance(
    String word,
    String partOfSpeech,
    String meaning, {
    required String apiKey,
    String? model,
  }) {
    final prompt =
        'Explain the subtle nuance, emotional tone, and usage context of the $partOfSpeech "$word" ($meaning) compared to common synonyms. Keep it clear, concise, and educational (2-3 short paragraphs max).';
    return streamContent(prompt, apiKey: apiKey, model: model);
  }

  Stream<String> streamContextExamples(
    String word,
    String partOfSpeech, {
    required String apiKey,
    String? model,
  }) {
    final prompt =
        'Provide 3 distinct, practical example sentences using the $partOfSpeech "$word" in: 1) Casual conversation, 2) Professional/workplace setting, 3) Literature/journalism. Number each example clearly.';
    return streamContent(prompt, apiKey: apiKey, model: model);
  }

  Stream<String> streamCustomPrompt(
    String word,
    String promptType, {
    required String apiKey,
    String? model,
  }) {
    String fullPrompt = '';
    switch (promptType) {
      case 'simple':
        fullPrompt = 'Explain the word "$word" in super simple terms that a 10-year-old would understand, with 1 clear example.';
        break;
      case 'story':
        fullPrompt = 'Write a short 3-sentence creative micro-story that naturally uses the word "$word". Highlight or emphasize "$word" in the story.';
        break;
      case 'synonyms':
        fullPrompt = 'List the top 4 synonyms for "$word" and explain the main difference between "$word" and each synonym in 1 bullet point each.';
        break;
      case 'etymology':
        fullPrompt = 'Explain the origin, historical root (Latin, Greek, Old English, etc.), and breakdown of the word "$word" in 2 brief paragraphs.';
        break;
      default:
        fullPrompt = 'Tell me an interesting vocabulary fact or usage tip about the word "$word".';
    }
    return streamContent(fullPrompt, apiKey: apiKey, model: model);
  }

  Stream<String> streamContent(
    String prompt, {
    required String apiKey,
    String? model,
  }) async* {
    final cleanKey = _cleanKey(apiKey);
    if (cleanKey.isEmpty) {
      throw Exception('Gemini API key is required. Please add your key in Settings.');
    }

    final modelsToTry = await _getModelsToTryDynamic(cleanKey, model);
    String lastError = 'Failed to generate real-time AI response.';

    for (final targetModel in modelsToTry) {
      final client = http.Client();
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:streamGenerateContent?alt=sse&key=$cleanKey',
        );

        final request = http.Request('POST', url);
        request.headers['Content-Type'] = 'application/json';
        request.headers['x-goog-api-key'] = cleanKey;
        request.body = jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        });

        final response = await client.send(request).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          bool emittedAny = false;
          String lineBuffer = '';

          await for (final chunk in response.stream.transform(utf8.decoder)) {
            lineBuffer += chunk;
            final lines = lineBuffer.split('\n');
            lineBuffer = lines.removeLast();

            for (final line in lines) {
              final trimmed = line.trim();
              if (trimmed.startsWith('data: ')) {
                final jsonStr = trimmed.substring(6).trim();
                if (jsonStr == '[DONE]') continue;
                try {
                  final data = jsonDecode(jsonStr);
                  final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
                  if (text != null && text.isNotEmpty) {
                    emittedAny = true;
                    yield text;
                  }
                } catch (_) {}
              }
            }
          }

          if (lineBuffer.trim().startsWith('data: ')) {
            final jsonStr = lineBuffer.trim().substring(6).trim();
            if (jsonStr != '[DONE]') {
              try {
                final data = jsonDecode(jsonStr);
                final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  emittedAny = true;
                  yield text;
                }
              } catch (_) {}
            }
          }

          if (emittedAny) {
            client.close();
            return;
          }
        } else {
          final bodyStr = await response.stream.bytesToString();
          String errorMsg;
          try {
            final body = jsonDecode(bodyStr);
            errorMsg = body['error']?['message'] ?? 'HTTP ${response.statusCode}';
          } catch (_) {
            errorMsg = 'HTTP ${response.statusCode}: $bodyStr';
          }

          if (response.statusCode == 401 || response.statusCode == 403) {
            client.close();
            throw Exception('Invalid or unauthorized API key ($errorMsg). Please check your key in Settings.');
          } else if (response.statusCode == 429) {
            client.close();
            throw Exception('Gemini AI quota exceeded / rate limited ($errorMsg). Try again later.');
          }
          lastError = errorMsg;
        }
      } on TimeoutException {
        lastError = 'Request timed out. Please check your internet connection.';
      } on SocketException {
        lastError = 'Network error. Please check your internet connection.';
      } catch (e) {
        if (e.toString().contains('Invalid or unauthorized') || e.toString().contains('quota exceeded')) {
          client.close();
          rethrow;
        }
        lastError = e.toString().replaceAll('Exception: ', '');
      } finally {
        client.close();
      }
    }

    throw Exception(lastError);
  }

  Future<String> _generateContent(
    String prompt, {
    required String apiKey,
    String? model,
  }) async {
    final cleanKey = _cleanKey(apiKey);
    if (cleanKey.isEmpty) {
      throw Exception('Gemini API key is required. Please add your key in Settings.');
    }

    final modelsToTry = await _getModelsToTryDynamic(cleanKey, model);
    String lastError = 'Failed to generate AI response.';

    for (final targetModel in modelsToTry) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent?key=$cleanKey',
      );

      try {
        final response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': cleanKey,
              },
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': 'Hello'}
                    ]
                  }
                ]
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
          if (text != null && text.trim().isNotEmpty) {
            return text.trim();
          }
          throw Exception('Empty response received from Gemini AI.');
        }

        String errorMsg;
        try {
          final body = jsonDecode(response.body);
          errorMsg = body['error']?['message'] ?? 'HTTP ${response.statusCode}';
        } catch (_) {
          errorMsg = 'HTTP ${response.statusCode}: ${response.reasonPhrase ?? response.body}';
        }

        if (response.statusCode == 400 || response.statusCode == 404) {
          lastError = errorMsg;
          continue;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          throw Exception('Invalid or unauthorized API key ($errorMsg). Please check your key in Settings.');
        } else if (response.statusCode == 429) {
          throw Exception('Gemini AI quota exceeded / rate limited ($errorMsg). Try again later.');
        } else {
          lastError = errorMsg;
        }
      } on TimeoutException {
        lastError = 'Request timed out. Please check your internet connection and try again.';
      } on SocketException {
        lastError = 'Network error. Please check your internet connection.';
      } catch (e) {
        if (e.toString().contains('Invalid or unauthorized') || e.toString().contains('quota exceeded')) {
          rethrow;
        }
        lastError = e.toString().replaceAll('Exception: ', '');
      }
    }

    throw Exception(lastError);
  }
}
