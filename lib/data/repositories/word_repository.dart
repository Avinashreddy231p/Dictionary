import '../../core/database/database.dart';

class WordRepository {
  final AppDatabase _db;
  
  WordRepository(this._db);
  
  Future<List<Word>> searchWords(String query) async {
    return _db.searchWords(query);
  }
  
  Future<Word?> getWordDetails(String query) async {
    final words = await _db.searchWords(query);
    if (words.isNotEmpty) return words.first;
    return null;
  }
  
  Future<List<Definition>> getWordDefinitions(int wordId) async {
    return (_db.select(_db.definitions)..where((t) => t.wordId.equals(wordId))).get();
  }
  
  Future<List<Example>> getDefinitionExamples(int definitionId) async {
    return (_db.select(_db.examples)..where((t) => t.definitionId.equals(definitionId))).get();
  }
}
