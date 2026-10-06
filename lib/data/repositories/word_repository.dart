import '../../core/database/database.dart';
import '../models/dictionary_entry.dart';
import '../services/merriam_webster_service.dart';

class WordRepository {
  final AppDatabase _db;
  final MerriamWebsterService _service;

  WordRepository(this._db, {MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<List<DictionaryEntry>> searchWord(String query) async {
    try {
      final apiResults = await _service.fetchWord(query);
      if (apiResults.isNotEmpty) return apiResults;
    } catch (_) {}

    // Fallback to local database if API fails or returns no results
    final saved = await _db.getSavedWordByWord(query);
    if (saved != null) {
      return [
        DictionaryEntry(
          word: saved.word,
          partOfSpeech: saved.partOfSpeech ?? 'word',
          phonetic: saved.phonetic ?? '',
          syllables: saved.syllables?.split('*') ?? [saved.word],
          meanings: [saved.meaning ?? 'Saved vocabulary word'],
          examples: saved.example != null ? [saved.example!] : [],
          synonyms: [],
          antonyms: [],
          inflections: [],
          grammaticalInfo: [],
          registers: [],
          domains: [],
          etymology: '',
        )
      ];
    }
    return [];
  }
}
