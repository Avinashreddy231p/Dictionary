import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/lexical_entry.dart';
import '../data/services/merriam_webster_service.dart';
import '../core/utils/fuzzy_search.dart';

class SearchResult {
  final List<LexicalEntry> entries;
  final List<String> suggestions;
  final bool isFuzzyMatch;
  final String? correctedQuery;
  final double? fuzzyConfidence;

  SearchResult({
    required this.entries,
    required this.suggestions,
    this.isFuzzyMatch = false,
    this.correctedQuery,
    this.fuzzyConfidence,
  });
}

class DictionaryRepository {
  final MerriamWebsterService _service;

  DictionaryRepository({MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<SearchResult> searchWord(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return SearchResult(entries: [], suggestions: []);

      // 1. Direct Search via Merriam-Webster API
      var mwResult = await _service.fetchWord(cleanQuery);

      if (mwResult.entries.isNotEmpty) {
        return _enrichAndReturn(cleanQuery, mwResult.entries, mwResult.suggestions);
      }

      // 2. Specialized Multi-Word Phrase & Idiom Resolution Engine
      if (cleanQuery.contains(' ')) {
        final phraseEntry = await _resolvePhraseWithDatamuse(cleanQuery);
        if (phraseEntry != null) {
          return SearchResult(
            entries: [phraseEntry.entry],
            suggestions: phraseEntry.relatedWords,
            isFuzzyMatch: false,
          );
        }

        // Try concatenated single-word variant (e.g. "micro interactions" -> "microinteractions")
        final noSpaces = cleanQuery.replaceAll(' ', '');
        final altResult = await _service.fetchWord(noSpaces);
        if (altResult.entries.isNotEmpty) {
          return _enrichAndReturn(
            noSpaces,
            altResult.entries,
            altResult.suggestions,
            isFuzzy: true,
            correctedQuery: noSpaces,
          );
        }

        // Try constituent key words (e.g. "advanced vocabulary" -> "vocabulary")
        final parts = cleanQuery.split(' ');
        for (var part in parts.reversed) {
          if (part.length > 2) {
            final partResult = await _service.fetchWord(part);
            if (partResult.entries.isNotEmpty) {
              return _enrichAndReturn(
                part,
                partResult.entries,
                partResult.suggestions,
                isFuzzy: true,
                correctedQuery: part,
              );
            }
          }
        }
      }

      // 3. Advanced Multi-Source Fuzzy Search
      List<String> rawSuggestions = List.from(mwResult.suggestions);

      // Fetch Datamuse spelling and phonetic candidates for fuzzy resolution
      try {
        final spRes = await http.get(
            Uri.parse('https://api.datamuse.com/words?sp=${Uri.encodeComponent(cleanQuery)}*&max=8'));
        if (spRes.statusCode == 200) {
          final data = json.decode(spRes.body) as List;
          for (var item in data) {
            final word = item['word'] as String;
            if (!rawSuggestions.contains(word)) {
              rawSuggestions.add(word);
            }
          }
        }

        final slRes = await http.get(
            Uri.parse('https://api.datamuse.com/words?sl=${Uri.encodeComponent(cleanQuery)}&max=8'));
        if (slRes.statusCode == 200) {
          final data = json.decode(slRes.body) as List;
          for (var item in data) {
            final word = item['word'] as String;
            if (!rawSuggestions.contains(word)) {
              rawSuggestions.add(word);
            }
          }
        }
      } catch (_) {}

      // Rank candidates using Levenshtein similarity distance
      final fuzzyMatches = FuzzySearch.rankMatches<String>(
        query: cleanQuery,
        candidates: rawSuggestions,
        wordExtractor: (s) => s,
        minSimilarity: 0.40,
        maxResults: 8,
      );

      final rankedSuggestions = fuzzyMatches.map((m) => m.word).toList();

      // If we have a high-confidence top fuzzy candidate, attempt auto-correction lookup
      if (fuzzyMatches.isNotEmpty) {
        final topMatch = fuzzyMatches.first;
        if (topMatch.similarity >= 0.55 || topMatch.distance <= 2) {
          final fuzzyMwResult = await _service.fetchWord(topMatch.word);
          if (fuzzyMwResult.entries.isNotEmpty) {
            return _enrichAndReturn(
              topMatch.word,
              fuzzyMwResult.entries,
              rankedSuggestions.where((s) => s != topMatch.word).toList(),
              isFuzzy: true,
              correctedQuery: topMatch.word,
              confidence: topMatch.similarity,
            );
          }
        }
      }

      return SearchResult(
        entries: [],
        suggestions: rankedSuggestions.isNotEmpty ? rankedSuggestions : rawSuggestions.take(8).toList(),
      );
    } catch (e) {
      return SearchResult(entries: [], suggestions: []);
    }
  }

  /// Resolves definitions and synonyms for phrases and idioms using Datamuse API (md=d, ml=phrase)
  Future<_PhraseResolution?> _resolvePhraseWithDatamuse(String phrase) async {
    try {
      final encodedPhrase = Uri.encodeComponent(phrase);

      // Query Datamuse "means like" (ml) with definitions (md=d)
      final mlUrl = 'https://api.datamuse.com/words?ml=$encodedPhrase&md=d&max=6';
      final response = await http.get(Uri.parse(mlUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) return null;

        String? foundDef;
        List<String> relatedWords = [];

        for (var item in data) {
          if (item is Map<String, dynamic>) {
            final word = item['word'] as String?;
            if (word != null && word != phrase) {
              relatedWords.add(word);
            }

            if (foundDef == null && item.containsKey('defs')) {
              final defsList = item['defs'] as List?;
              if (defsList != null && defsList.isNotEmpty) {
                final rawDef = defsList.first as String;
                // Strip POS prefix e.g. "n\tsomething easy" -> "something easy"
                foundDef = rawDef.replaceAll(RegExp(r'^[a-z]+\t'), '').trim();
              }
            }
          }
        }

        if (foundDef == null || foundDef.isEmpty) {
          foundDef = 'An idiomatic phrase or multi-word expression meaning "${relatedWords.take(3).join(', ')}".';
        }

        final entry = LexicalEntry(
          core: CoreData(
            headword: phrase,
            homograph: 0,
            partOfSpeech: 'phrase / idiom',
            phonetic: '',
            audioUrl: '',
            syllables: phrase.split(' '),
          ),
          senses: [
            Sense(
              senseNumber: '1',
              definition: foundDef,
              examples: [
                'Commonly used as an idiomatic expression in conversational English.'
              ],
              labels: ['phrase', 'idiom'],
            )
          ],
          grammar: GrammarData(
            verbDivision: '',
            usageNotes: [],
            inflections: [],
            relatedForms: [],
          ),
          linguistic: LinguisticData(
            etymology: 'English phrase',
            firstKnownUse: '',
          ),
          lexiLens: LexiLensLayer(
            simpleMeaning: foundDef,
            contextualMeaning: 'Idiomatic usage in context.',
            synonyms: relatedWords.take(8).toList(),
            antonyms: [],
          ),
        );

        return _PhraseResolution(entry: entry, relatedWords: relatedWords.take(6).toList());
      }
    } catch (_) {}
    return null;
  }

  Future<SearchResult> _enrichAndReturn(
    String term,
    List<LexicalEntry> entries,
    List<String> suggestions, {
    bool isFuzzy = false,
    String? correctedQuery,
    double? confidence,
  }) async {
    List<String> synonyms = [];
    List<String> antonyms = [];
    try {
      final res = await http.get(Uri.parse('https://api.datamuse.com/words?rel_syn=$term'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        synonyms = data.take(10).map((e) => e['word'] as String).toList();
      }

      final antRes = await http.get(Uri.parse('https://api.datamuse.com/words?rel_ant=$term'));
      if (antRes.statusCode == 200) {
        final data = json.decode(antRes.body) as List;
        antonyms = data.take(5).map((e) => e['word'] as String).toList();
      }
    } catch (_) {}

    final enrichedEntries = entries.map((entry) {
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

    return SearchResult(
      entries: enrichedEntries,
      suggestions: suggestions,
      isFuzzyMatch: isFuzzy,
      correctedQuery: correctedQuery,
      fuzzyConfidence: confidence,
    );
  }
}

class _PhraseResolution {
  final LexicalEntry entry;
  final List<String> relatedWords;

  _PhraseResolution({required this.entry, required this.relatedWords});
}
