import '../models/dictionary_entry.dart';

class MerriamWebsterService {
  // A mock implementation of the service
  Future<List<DictionaryEntry>> fetchWord(String query) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    if (query.toLowerCase() == 'reluctant') {
      return [
        DictionaryEntry(
          word: 'reluctant',
          partOfSpeech: 'adjective',
          phonetic: '/rɪˈlʌktənt/',
          meaning: 'Not wanting to do something.',
          example: 'She was reluctant to leave the party.',
        ),
      ];
    }
    
    return [];
  }
}