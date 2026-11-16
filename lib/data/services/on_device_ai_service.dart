import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';

class OnDeviceModelDetails {
  final String id;
  final String name;
  final String sizeDescription;
  final String recommendedHardware;

  const OnDeviceModelDetails({
    required this.id,
    required this.name,
    required this.sizeDescription,
    required this.recommendedHardware,
  });
}

class OnDeviceAiService {
  static const List<OnDeviceModelDetails> availableModels = [
    OnDeviceModelDetails(
      id: 'lfm2_5_230m',
      name: 'LFM 2.5 (230M) - Recommended Public',
      sizeDescription: '~150 MB • Ungated Public Model',
      recommendedHardware: 'Ultra-fast & works on all devices without API keys or tokens',
    ),
    OnDeviceModelDetails(
      id: 'qwen3_06b',
      name: 'Qwen3 (0.6B) - High Quality Public',
      sizeDescription: '~400 MB • Ungated Public Model',
      recommendedHardware: 'Great reasoning & works without HF token',
    ),
    OnDeviceModelDetails(
      id: 'fastvlm0_5b',
      name: 'FastVLM (0.5B)',
      sizeDescription: '~300 MB • Ungated Public Model',
      recommendedHardware: 'Fast multimodal vision & text model',
    ),
    OnDeviceModelDetails(
      id: 'gemma3_270m',
      name: 'Gemma 3 (270M)',
      sizeDescription: '~200 MB • HF Gated Repo',
      recommendedHardware: 'Ultra-fast (Requires HF token)',
    ),
    OnDeviceModelDetails(
      id: 'gemma4_e2b',
      name: 'Gemma 4 (E2B)',
      sizeDescription: '~1.2 GB • HF Gated Repo',
      recommendedHardware: 'High-RAM devices (Requires HF token)',
    ),
  ];

  static const List<OnDeviceModelDetails> availableEmbeddingModels = [
    OnDeviceModelDetails(
      id: 'embeddinggemma2_270m',
      name: 'EmbeddingGemma 2 (270M)',
      sizeDescription: '~250 MB',
      recommendedHardware: 'Required for offline Concept Search',
    ),
  ];

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadStatusText;

  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get downloadStatusText => _downloadStatusText;

  InferenceVariant _getLiteRtModel(String modelId) {
    switch (modelId) {
      case 'qwen3_06b':
        return LiteRtLmModels.qwen3_0_6b.dynamicInt4;
      case 'fastvlm0_5b':
        return LiteRtLmModels.fastvlm0_5b.generic;
      case 'gemma4_e2b':
        return LiteRtLmModels.gemma4E2bIt.generic;
      case 'gemma3_270m':
        return LiteRtLmModels.gemma3_270mIt.q8;
      case 'lfm2_5_230m':
      default:
        return LiteRtLmModels.lfm2_5_230m.int4;
    }
  }

  String _getFileName(String modelId) {
    switch (modelId) {
      case 'qwen3_06b':
        return LiteRtLmModels.qwen3_0_6b.dynamicInt4.file.installFilename;
      case 'fastvlm0_5b':
        return LiteRtLmModels.fastvlm0_5b.generic.file.installFilename;
      case 'gemma4_e2b':
        return LiteRtLmModels.gemma4E2bIt.generic.file.installFilename;
      case 'gemma3_270m':
        return LiteRtLmModels.gemma3_270mIt.q8.file.installFilename;
      case 'lfm2_5_230m':
      default:
        return LiteRtLmModels.lfm2_5_230m.int4.file.installFilename;
    }
  }

  LiteRtEmbedderVariant _getLiteRtEmbeddingModel(String modelId) {
    return LiteRtEmbedders.embeddinggemma2Text270m.generic;
  }

  String _getEmbeddingFileName(String modelId) {
    return LiteRtEmbedders.embeddinggemma2Text270m.generic.model.installFilename;
  }

  /// Download and install model from catalog with progress callback
  Future<bool> installModel({
    required String modelId,
    String? hfToken,
    void Function(double progress, String status)? onProgress,
  }) async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    _downloadStatusText = 'Starting download...';
    onProgress?.call(0.0, _downloadStatusText!);

    try {
      final targetModel = _getLiteRtModel(modelId);
      final authToken = hfToken != null && hfToken.trim().isNotEmpty ? hfToken.trim() : null;
      final installer = FlutterEdgeAi.installModelFromCatalog(
        targetModel,
        token: authToken,
      ).withProgress((percent) {
        _downloadProgress = percent / 100.0;
        _downloadStatusText = 'Downloading model... ${percent.toStringAsFixed(1)}%';
        onProgress?.call(_downloadProgress, _downloadStatusText!);
      });

      await installer.install();

      _downloadProgress = 1.0;
      _downloadStatusText = 'Installation Complete!';
      onProgress?.call(1.0, _downloadStatusText!);
      _isDownloading = false;
      return true;
    } catch (e) {
      debugPrint('OnDeviceAiService: Model Download failed - $e');
      final errStr = e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', '');
      if (errStr.contains('401') || errStr.contains('403') || errStr.contains('gated')) {
        _downloadStatusText = 'Gated Model Error (401/403): Needs HF Token. Please select LFM 2.5 or Qwen3!';
      } else {
        _downloadStatusText = 'Download Failed: $errStr';
      }
      onProgress?.call(0.0, _downloadStatusText!);
      _isDownloading = false;
      return false;
    }
  }

  Future<void> deleteModel(String modelId) async {
    try {
      final fileName = _getFileName(modelId);
      final isInstalled = await FlutterEdgeAi.isModelInstalled(fileName);
      if (isInstalled) {
        await FlutterEdgeAi.uninstallModel(fileName);
      }
    } catch (e) {
      debugPrint('OnDeviceAiService: Failed to delete model - $e');
    }
  }

  /// Check which models from the catalog are already installed
  Future<Map<String, bool>> getInstalledModelsStatus() async {
    final statusMap = <String, bool>{};
    for (final model in availableModels) {
      try {
        final fileName = _getFileName(model.id);
        statusMap[model.id] = await FlutterEdgeAi.isModelInstalled(fileName);
      } catch (e) {
        statusMap[model.id] = false;
      }
    }
    return statusMap;
  }

  /// Check if a specific model is downloaded and ready
  Future<bool> isModelReady(String modelId) async {
    try {
      final fileName = _getFileName(modelId);
      return await FlutterEdgeAi.isModelInstalled(fileName);
    } catch (_) {
      return false;
    }
  }

  /// Generate word definition & details using JSON Schema constrained decoding
  Future<Map<String, dynamic>?> generateWordDefinitionJson(String word, String modelId) async {
    try {
      if (!await isModelReady(modelId)) return null;
      final activeModel = await FlutterEdgeAi.getActiveModel(defaults: _getLiteRtModel(modelId).runtimeDefaults);
      if (activeModel == null) return null;

      final responseFormat = ResponseFormat.jsonSchema({
        'type': 'object',
        'properties': {
          'word': {'type': 'string'},
          'phonetic': {'type': 'string'},
          'partOfSpeech': {'type': 'string'},
          'definition': {'type': 'string'},
          'example': {'type': 'string'},
          'cefr': {
            'type': 'string',
            'enum': ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
          },
          'synonyms': {
            'type': 'array',
            'items': {'type': 'string'}
          },
        },
        'required': ['word', 'partOfSpeech', 'definition', 'example'],
        'additionalProperties': false,
      });

      final session = await activeModel.openSession(responseFormat: responseFormat);
      try {
        final prompt = 'Provide a concise dictionary entry for the English word: "$word"';
        await session.addQueryChunk(Message(text: prompt, isUser: true));
        final responseText = await session.getResponse();
        final decoded = jsonDecode(responseText);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } finally {
        await session.close();
      }
    } catch (e) {
      debugPrint('OnDeviceAiService: generateWordDefinitionJson failed - $e');
    }
    return null;
  }

  /// Stream simple explanation for a word or phrase
  Stream<String> streamExplanation(String prompt, String modelId, {int maxOutputTokens = 1000}) async* {
    try {
      if (!await isModelReady(modelId)) {
        yield 'On-device model is not installed. Please download it in AI Settings.';
        return;
      }
      
      final activeModel = await FlutterEdgeAi.getActiveModel(defaults: _getLiteRtModel(modelId).runtimeDefaults);
      if (activeModel == null) {
        yield 'On-device model failed to load.';
        return;
      }

      final session = await activeModel.openSession(
        temperature: 0.2,
        topK: 20,
        maxOutputTokens: maxOutputTokens,
      );
      try {
        await session.addQueryChunk(Message(text: prompt, isUser: true));
        yield* session.getResponseAsync();
      } finally {
        await session.close();
      }
    } catch (e) {
      yield 'Error during local AI generation: $e';
    }
  }

  /// Fast CEFR word rating using LiteTune Deciders
  Future<String> rateWordDifficulty(String word) async {
    try {
      final activeEmbedder = await FlutterEdgeAi.getActiveEmbedder();
      final decider = await activeEmbedder.createDecider(
        options: [
          DeciderOption('A1'),
          DeciderOption('A2'),
          DeciderOption('B1'),
          DeciderOption('B2'),
          DeciderOption('C1'),
          DeciderOption('C2'),
        ],
      );

      final answer = await decider.choose(
        DeciderInput(EmbeddingInput.text('What is the difficulty of the word "$word"?')),
      );
      return answer.choice ?? 'B2';
    } catch (e) {
      debugPrint('OnDeviceAiService: decider failed - $e');
    }
    return 'B2';
  }

  // --- EMBEDDING METHODS ---

  Future<bool> installEmbeddingModel({
    required String modelId,
    void Function(double progress, String status)? onProgress,
  }) async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    _downloadStatusText = 'Starting embedding model download...';
    onProgress?.call(0.0, _downloadStatusText!);

    try {
      final targetModel = _getLiteRtEmbeddingModel(modelId);
      final installer = FlutterEdgeAi.installEmbedder()
          .fromCatalog(targetModel)
          .withProgress((percent) {
        _downloadProgress = percent / 100.0;
        _downloadStatusText = 'Downloading... ${percent.toStringAsFixed(1)}%';
        onProgress?.call(_downloadProgress, _downloadStatusText!);
      });

      await installer.install();

      _downloadProgress = 1.0;
      _downloadStatusText = 'Installation Complete!';
      onProgress?.call(1.0, _downloadStatusText!);
      _isDownloading = false;
      return true;
    } catch (e) {
      debugPrint('OnDeviceAiService: Embedding Model Download failed - $e');
      _downloadStatusText = 'Download Failed: $e';
      onProgress?.call(0.0, _downloadStatusText!);
      _isDownloading = false;
      return false;
    }
  }

  Future<bool> isEmbeddingModelReady(String modelId) async {
    try {
      final fileName = _getEmbeddingFileName(modelId);
      return await FlutterEdgeAi.isModelInstalled(fileName);
    } catch (_) {
      return false;
    }
  }

  Future<Float32List?> generateEmbedding(String text, String modelId) async {
    try {
      if (!await isEmbeddingModelReady(modelId)) return null;
      final activeEmbedder = await FlutterEdgeAi.getActiveEmbedder();
      final List<double> doubleList = await activeEmbedder.embed(
        EmbeddingInput.text(text),
        taskType: TaskType.sentenceSimilarity,
      );
      return Float32List.fromList(doubleList);
    } catch (e) {
      debugPrint('OnDeviceAiService: generateEmbedding failed - $e');
      return null;
    }
  }
}
