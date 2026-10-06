import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/lexical_entry.dart';
import '../data/services/merriam_webster_service.dart';

class SearchResult {
  final List<LexicalEntry> entries;
  final List<String> suggestions;

  SearchResult({required this.entries, required this.suggestions});
}

class DictionaryRepository {
  final MerriamWebsterService _service;

  DictionaryRepository({MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<SearchResult> searchWord(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return SearchResult(entries: [], suggestions: []);

      // 1. Direct Search
      var mwResult = await _service.fetchWord(cleanQuery);

      // 2. Fallback for Multi-Word Queries (e.g. "micro interactions")
      if (mwResult.entries.isEmpty && cleanQuery.contains(' ')) {
        // Try concatenated word (e.g. "microinteraction")
        final noSpaces = cleanQuery.replaceAll(' ', '');
        final altResult = await _service.fetchWord(noSpaces);
        if (altResult.entries.isNotEmpty) {
          mwResult = altResult;
        } else {
          // Try individual constituent words (e.g. "interaction")
          final parts = cleanQuery.split(' ');
          for (var part in parts.reversed) {
            if (part.length > 2) {
              final partResult = await _service.fetchWord(part);
              if (partResult.entries.isNotEmpty) {
                mwResult = MwFetchResult(
                  entries: partResult.entries,
                  suggestions: mwResult.suggestions,
                );
                break;
              }
            }
          }
        }
      }

      if (mwResult.entries.isEmpty) {
        // Return suggestions (or Datamuse fallback suggestions)
        List<String> suggestions = List.from(mwResult.suggestions);
        if (suggestions.isEmpty) {
          try {
            final res = await http.get(Uri.parse('https://api.datamuse.com/words?sp=$cleanQuery*&max=6'));
            if (res.statusCode == 200) {
              final data = json.decode(res.body) as List;
              suggestions = data.map((e) => e['word'] as String).toList();
            }
          } catch (_) {}
        }

        return SearchResult(entries: [], suggestions: suggestions.take(8).toList());
      }

      // Fetch Datamuse synonyms and antonyms for found entries
      List<String> synonyms = [];
      List<String> antonyms = [];
      try {
        final res = await http.get(Uri.parse('https://api.datamuse.com/words?rel_syn=$cleanQuery'));
        if (res.statusCode == 200) {
          final data = json.decode(res.body) as List;
          synonyms = data.take(10).map((e) => e['word'] as String).toList();
        }
        
        final antRes = await http.get(Uri.parse('https://api.datamuse.com/words?rel_ant=$cleanQuery'));
        if (antRes.statusCode == 200) {
          final data = json.decode(antRes.body) as List;
          antonyms = data.take(5).map((e) => e['word'] as String).toList();
        }
      } catch (_) {}

      final enrichedEntries = mwResult.entries.map((entry) {
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

      return SearchResult(entries: enrichedEntries, suggestions: mwResult.suggestions);
    } catch (e) {
      return SearchResult(entries: [], suggestions: []);
    }
  }
}
