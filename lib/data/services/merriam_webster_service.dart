import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lexical_entry.dart';

class MerriamWebsterService {
  final String _apiKey = '0267f50a-024b-4a82-86ea-7d2c12f3e564';
  final String _baseUrl = 'https://dictionaryapi.com/api/v3/references/collegiate/json';

  Future<List<LexicalEntry>> fetchWord(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$query?key=$_apiKey'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // If the API returns a list of string suggestions when the word isn't found
        if (data.isNotEmpty && data.first is String) {
          return [];
        }

        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => LexicalEntry.fromMwJson(json))
            .toList();
      } else {
        throw Exception('Failed to load dictionary data');
      }
    } catch (e) {
      throw Exception('Error fetching word: $e');
    }
  }
}