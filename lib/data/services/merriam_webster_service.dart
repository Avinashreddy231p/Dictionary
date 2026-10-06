import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lexical_entry.dart';

class MwFetchResult {
  final List<LexicalEntry> entries;
  final List<String> suggestions;

  MwFetchResult({required this.entries, required this.suggestions});
}

class MerriamWebsterService {
  final String _apiKey = '0267f50a-024b-4a82-86ea-7d2c12f3e564';
  final String _baseUrl = 'https://dictionaryapi.com/api/v3/references/collegiate/json';

  Future<MwFetchResult> fetchWord(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      final response = await http.get(Uri.parse('$_baseUrl/$cleanQuery?key=$_apiKey'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return MwFetchResult(entries: [], suggestions: []);
        }

        // If the API returns a list of string suggestions when the word isn't found
        if (data.first is String) {
          final suggestions = data.whereType<String>().toList();
          return MwFetchResult(entries: [], suggestions: suggestions);
        }

        final entries = data
            .whereType<Map<String, dynamic>>()
            .map((json) => LexicalEntry.fromMwJson(json))
            .toList();

        return MwFetchResult(entries: entries, suggestions: []);
      } else {
        debugPrint('MerriamWebsterService HTTP status: ${response.statusCode}');
        return MwFetchResult(entries: [], suggestions: []);
      }
    } catch (e) {
      debugPrint('MerriamWebsterService network error: $e');
      return MwFetchResult(entries: [], suggestions: []);
    }
  }
}
