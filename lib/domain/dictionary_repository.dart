import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/database/database.dart';
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
  final AppDatabase? _db;

  DictionaryRepository({
    MerriamWebsterService? service,
    AppDatabase? db,
  })  : _service = service ?? MerriamWebsterService(),
        _db = db;

  Future<List<String>> getAutoSuggestions(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final List<String> suggestions = [];

    // 1. Fetch offline SQLite DB suggestions
    if (_db != null) {
      try {
        final offlineSuggestions = await _db!.getOfflineSuggestions(cleanQuery);
        for (final s in offlineSuggestions) {
          if (!suggestions.contains(s)) {
            suggestions.add(s);
          }
        }
      } catch (_) {}
    }

    // 2. Fetch online Datamuse auto-complete suggestions if suggestions < 5
    if (suggestions.length < 5) {
      try {
        final uri = Uri.parse('https://api.datamuse.com/sug?s=${Uri.encodeComponent(cleanQuery)}&max=5');
        final response = await http.get(uri).timeout(const Duration(milliseconds: 800));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          for (var item in data) {
            if (item is Map<String, dynamic> && item.containsKey('word')) {
              final w = item['word'] as String?;
              if (w != null && !suggestions.contains(w)) {
                suggestions.add(w);
              }
            }
          }
        }
      } catch (_) {}
    }

    return suggestions.take(5).toList();
  }

  Future<SearchResult> searchWord(String query) async {
    try {
      final cleanQuery = query.trim().toLowerCase();
      if (cleanQuery.isEmpty) return SearchResult(entries: [], suggestions: []);

      // 1. Direct Search via Merriam-Webster API (Online)
      try {
        var mwResult = await _service.fetchWord(cleanQuery);
        if (mwResult.entries.isNotEmpty) {
          return _enrichAndReturn(cleanQuery, mwResult.entries, mwResult.suggestions);
        }
      } catch (_) {
        // Online API failed or offline
      }

      // 2. Check Saved Words in local AppDatabase
      if (_db != null) {
        try {
          final savedWord = await _db.getSavedWordByWord(cleanQuery);
          if (savedWord != null) {
            final entry = _convertSavedToLexicalEntry(savedWord);
            return SearchResult(entries: [entry], suggestions: []);
          }
        } catch (_) {}
      }

      // 3. Fallback to Offline Backup Dictionary Database (english Dictionary.csv dataset)
      if (_db != null) {
        try {
          final offlineEntry = await _db.getOfflineWord(cleanQuery);
          if (offlineEntry != null) {
            return SearchResult(
              entries: [offlineEntry],
              suggestions: [],
              isFuzzyMatch: false,
            );
          }

          // Fuzzy search in offline backup database
          final offlineFuzzy = await _db.searchOfflineWordsFuzzy(cleanQuery);
          if (offlineFuzzy.isNotEmpty) {
            final suggestions = offlineFuzzy.map((e) => e.core.headword).toList();
            return SearchResult(
              entries: [offlineFuzzy.first],
              suggestions: suggestions.skip(1).toList(),
              isFuzzyMatch: true,
              correctedQuery: offlineFuzzy.first.core.headword,
            );
          }
        } catch (_) {}
      }

      // 4. Specialized Multi-Word Phrase & Idiom Resolution Engine
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
        try {
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
        } catch (_) {}

        // Try constituent key words
        final parts = cleanQuery.split(' ');
        for (var part in parts.reversed) {
          if (part.length > 2) {
            try {
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
            } catch (_) {}
          }
        }
      }

      // 5. Advanced Multi-Source Fuzzy Search
      List<String> rawSuggestions = [];

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

      final fuzzyMatches = FuzzySearch.rankMatches<String>(
        query: cleanQuery,
        candidates: rawSuggestions,
        wordExtractor: (s) => s,
        minSimilarity: 0.40,
        maxResults: 8,
      );

      final rankedSuggestions = fuzzyMatches.map((m) => m.word).toList();

      if (fuzzyMatches.isNotEmpty) {
        final topMatch = fuzzyMatches.first;
        if (topMatch.similarity >= 0.55 || topMatch.distance <= 2) {
          try {
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
          } catch (_) {}
        }
      }

      // 6. Synthesize definition for modern / informal / long words (e.g. supercalifragilisticexpialidocious)
      final synthesized = await _synthesizeInformalWordEntry(cleanQuery);
      if (synthesized != null) {
        return SearchResult(
          entries: [synthesized],
          suggestions: rawSuggestions.where((s) => s.toLowerCase() != cleanQuery).take(8).toList(),
          isFuzzyMatch: false,
        );
      }

      final filteredSuggestions = (rankedSuggestions.isNotEmpty ? rankedSuggestions : rawSuggestions)
          .where((s) => s.toLowerCase() != cleanQuery)
          .take(8)
          .toList();

      return SearchResult(
        entries: [],
        suggestions: filteredSuggestions,
      );
    } catch (e) {
      return SearchResult(entries: [], suggestions: []);
    }
  }

  Future<LexicalEntry?> _synthesizeInformalWordEntry(String word) async {
    try {
      final cleanWord = word.trim().toLowerCase();

      // Special handler for well-known long/informal words
      if (cleanWord == 'supercalifragilisticexpialidocious') {
        return LexicalEntry(
          core: CoreData(
            headword: 'supercalifragilisticexpialidocious',
            homograph: 0,
            partOfSpeech: 'adjective (informal)',
            phonetic: '/ ˌsuːpərˌkælɪˌfrædʒəlˌɪstɪkˌɛkspiˌælɪˈdoʊʃəs /',
            audioUrl: '',
            syllables: ['su', 'per', 'cali', 'frag', 'i', 'lis', 'tic', 'ex', 'pi', 'ali', 'do', 'cious'],
          ),
          senses: [
            Sense(
              senseNumber: '1',
              definition: 'Extraordinarily wonderful; fantastically good. Used as a humorous nonsense word to express approval or amazement.',
              examples: [
                'The atmosphere at the festival was supercalifragilisticexpialidocious!'
              ],
              labels: ['informal', 'pop culture'],
            )
          ],
          grammar: GrammarData(
            verbDivision: '',
            usageNotes: ['Popularized by the 1964 Disney musical film Mary Poppins.'],
            inflections: [],
            relatedForms: [],
          ),
          linguistic: LinguisticData(
            etymology: 'Coined by songwriters Richard M. and Robert B. Sherman (1964).',
            firstKnownUse: '1964',
          ),
          dictionaryLayer: DictionaryLayer(
            simpleMeaning: 'Extraordinarily wonderful; fantastically good.',
            contextualMeaning: 'Expressing extreme joy, wonder, or approval.',
            synonyms: ['wonderful', 'fantastic', 'extraordinary', 'marvelous', 'sensational'],
            antonyms: ['terrible', 'awful', 'dreadful'],
          ),
        );
      }

      // Query Datamuse "speller" or "means like" with definitions
      final uri = Uri.parse('https://api.datamuse.com/words?sp=$cleanWord&md=d&max=1');
      final res = await http.get(uri).timeout(const Duration(seconds: 1));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        if (data.isNotEmpty && data.first is Map<String, dynamic>) {
          final item = data.first as Map<String, dynamic>;
          final defs = item['defs'] as List?;
          if (defs != null && defs.isNotEmpty) {
            final rawDef = defs.first.toString().replaceAll(RegExp(r'^[a-z]+\t'), '').trim();
            return LexicalEntry(
              core: CoreData(
                headword: cleanWord,
                homograph: 0,
                partOfSpeech: 'word / expression',
                phonetic: '',
                audioUrl: '',
                syllables: [cleanWord],
              ),
              senses: [
                Sense(
                  senseNumber: '1',
                  definition: rawDef,
                  examples: [],
                  labels: ['expression'],
                )
              ],
              grammar: GrammarData(verbDivision: '', usageNotes: [], inflections: [], relatedForms: []),
              linguistic: LinguisticData(etymology: 'English term', firstKnownUse: ''),
              dictionaryLayer: DictionaryLayer(
                simpleMeaning: rawDef,
                contextualMeaning: 'General usage.',
                synonyms: [],
                antonyms: [],
              ),
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  LexicalEntry _convertSavedToLexicalEntry(SavedWord saved) {
    final headword = saved.word;
    final pos = saved.partOfSpeech ?? 'word';
    final phonetic = saved.phonetic ?? '';
    final meaning = saved.meaning ?? 'Saved vocabulary word';
    final example = saved.example;
    final syllables = saved.syllables?.split('*') ?? [headword];

    return LexicalEntry(
      core: CoreData(
        headword: headword,
        homograph: 0,
        partOfSpeech: pos,
        phonetic: phonetic,
        audioUrl: '',
        syllables: syllables,
      ),
      senses: [
        Sense(
          senseNumber: '1',
          definition: meaning,
          examples: example != null ? [example] : [],
          labels: [],
        )
      ],
      grammar: GrammarData(
        verbDivision: '',
        usageNotes: [],
        inflections: [],
        relatedForms: [],
      ),
      linguistic: LinguisticData(
        etymology: '',
        firstKnownUse: '',
      ),
      dictionaryLayer: DictionaryLayer(
        simpleMeaning: meaning,
        contextualMeaning: saved.contextSentence ?? '',
        synonyms: [],
        antonyms: [],
      ),
    );
  }

  /// Resolves definitions and synonyms for phrases and idioms using Datamuse API (md=d, ml=phrase)
  Future<_PhraseResolution?> _resolvePhraseWithDatamuse(String phrase) async {
    try {
      final encodedPhrase = Uri.encodeComponent(phrase);

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
          dictionaryLayer: DictionaryLayer(
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
        dictionaryLayer: entry.dictionaryLayer.copyWith(
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
