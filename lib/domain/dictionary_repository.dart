import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/lexical_entry.dart';
import '../data/services/merriam_webster_service.dart';

class DictionaryRepository {
  final MerriamWebsterService _service;

  DictionaryRepository({MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<List<LexicalEntry>> searchWord(String query) async {
    try {
      final mwResults = await _service.fetchWord(query);
      if (mwResults.isEmpty) return [];

      // Fetch Datamuse synonyms and antonyms
      List<String> synonyms = [];
      List<String> antonyms = [];
      try {
        final res = await http.get(Uri.parse('https://api.datamuse.com/words?rel_syn=$query'));
        if (res.statusCode == 200) {
          final data = json.decode(res.body) as List;
          synonyms = data.take(10).map((e) => e['word'] as String).toList();
        }
        
        final antRes = await http.get(Uri.parse('https://api.datamuse.com/words?rel_ant=$query'));
        if (antRes.statusCode == 200) {
          final data = json.decode(antRes.body) as List;
          antonyms = data.take(5).map((e) => e['word'] as String).toList();
        }
      } catch (_) {
        // Datamuse network errors fail gracefully
      }

      // Enrich entries with Datamuse relational data
      return mwResults.map((entry) {
        return LexicalEntry(
          core: entry.core,
          senses: entry.senses,
          grammar: entry.grammar,
          linguistic: entry.linguistic,
          lexiLens: entry.lexiLens.copyWith(
            synonyms: synonyms,
            antonyms: antonyms,
          ),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}