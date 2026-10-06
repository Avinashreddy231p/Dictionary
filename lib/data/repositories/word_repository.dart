import '../../core/database/database.dart';
import '../models/lexical_entry.dart';
import '../services/merriam_webster_service.dart';

class WordRepository {
  final AppDatabase _db;
  final MerriamWebsterService _service;

  WordRepository(this._db, {MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<List<LexicalEntry>> searchWord(String query) async {
    try {
      final apiResults = await _service.fetchWord(query);
      if (apiResults.isNotEmpty) return apiResults;
    } catch (_) {}

    // Fallback to local database if API fails or returns no results
    final saved = await _db.getSavedWordByWord(query);
    if (saved != null) {
      final headword = saved.word;
      final pos = saved.partOfSpeech ?? 'word';
      final phonetic = saved.phonetic ?? '';
      final meaning = saved.meaning ?? 'Saved vocabulary word';
      final example = saved.example;
      final syllables = saved.syllables?.split('*') ?? [headword];

      return [
        LexicalEntry(
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
          lexiLens: LexiLensLayer(
            simpleMeaning: meaning,
            contextualMeaning: saved.contextSentence ?? '',
            synonyms: [],
            antonyms: [],
          ),
        )
      ];
    }
    return [];
  }
}
