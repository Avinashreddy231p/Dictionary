import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/dictionary_entry.dart';
import '../data/services/merriam_webster_service.dart';

class DictionaryRepository {
  final MerriamWebsterService _service;

  DictionaryRepository({MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<List<DictionaryEntry>> searchWord(String query) async {
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
        // Silently fail if Datamuse fails, MW results are more important
      }

      // Enrich the results with Datamuse data
      return mwResults.map((entry) {
        return DictionaryEntry(
          word: entry.word,
          partOfSpeech: entry.partOfSpeech,
          phonetic: entry.phonetic,
          syllables: entry.syllables,
          meanings: entry.meanings,
          examples: entry.examples,
          synonyms: synonyms,
          antonyms: antonyms,
          inflections: entry.inflections,
          grammaticalInfo: entry.grammaticalInfo,
          registers: entry.registers,
          domains: entry.domains,
          etymology: entry.etymology,
          audioUrl: entry.audioUrl,
        );
      }).toList();
    } catch (e) {
      // Log error, rethrow, or return empty list based on strategy
      return [];
    }
  }
}