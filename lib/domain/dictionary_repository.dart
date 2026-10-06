import '../data/models/dictionary_entry.dart';
import '../data/services/merriam_webster_service.dart';

class DictionaryRepository {
  final MerriamWebsterService _service;

  DictionaryRepository({MerriamWebsterService? service})
      : _service = service ?? MerriamWebsterService();

  Future<List<DictionaryEntry>> searchWord(String query) async {
    try {
      return await _service.fetchWord(query);
    } catch (e) {
      // Log error, rethrow, or return empty list based on strategy
      return [];
    }
  }
}