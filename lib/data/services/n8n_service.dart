import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/n8n_config.dart';

class N8nService {
  final String _webhookUrl;

  N8nService({String? customWebhookUrl})
      : _webhookUrl = customWebhookUrl ?? N8nConfig.defaultWebhookUrl;

  String get webhookUrl => _webhookUrl;

  /// Tests the connection to the n8n webhook endpoint.
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': 'test_connection',
          'environment': N8nConfig.environment,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  /// Sends a vocabulary word event to n8n workflow automation.
  Future<bool> sendWordEvent({
    required String word,
    required String action, // e.g. 'saved', 'searched', 'mastered'
    String? meaning,
    String? partOfSpeech,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'event': action,
          'word': word,
          'meaning': meaning ?? '',
          'partOfSpeech': partOfSpeech ?? '',
          'environment': N8nConfig.environment,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}
