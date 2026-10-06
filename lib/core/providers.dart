import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import '../data/repositories/word_repository.dart';
import '../domain/dictionary_repository.dart';
import '../data/services/gemini_service.dart';
import '../data/services/offline_dictionary_service.dart';
import 'providers/settings_provider.dart';

export 'providers/settings_provider.dart';
export '../data/services/gemini_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Ensure database is seeded on startup
  db.seedDatabase();
  ref.onDispose(db.close);
  return db;
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WordRepository(db);
});

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DictionaryRepository(db: db);
});

final offlineDictionaryServiceProvider = Provider<OfflineDictionaryService>((ref) {
  final db = ref.watch(databaseProvider);
  return OfflineDictionaryService(db);
});

final offlineWordsCountStreamProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchOfflineWordsCount();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final settings = ref.watch(settingsProvider);
  return GeminiService(defaultModel: settings.geminiModel);
});

// Trigger to open keyboard on Search screen when Search bottom nav icon is tapped/double-tapped
class SearchFocusNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}

final searchFocusTriggerProvider = NotifierProvider<SearchFocusNotifier, int>(SearchFocusNotifier.new);

// Saved Words Providers
final savedWordsStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllSavedWords();
});

final todaySavedWordsStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTodaySavedWords();
});

final recentSavedWordsProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentSavedWords();
});

final favoritesStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchFavorites();
});

final needsReviewStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchNeedsReview();
});

final wordsWithSourceStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchWordsWithSource();
});

final masteredWordsStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchMasteredWords();
});

final wordsWithNotesStreamProvider = StreamProvider<List<SavedWord>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchWordsWithNotes();
});

final isWordSavedStreamProvider = StreamProvider.family<bool, String>((ref, word) {
  final db = ref.watch(databaseProvider);
  return db.watchSavedWordByWord(word).map((saved) => saved != null);
});

final savedWordStreamProvider = StreamProvider.family<SavedWord?, String>((ref, word) {
  final db = ref.watch(databaseProvider);
  return db.watchSavedWordByWord(word);
});

// Collections Providers
final userCollectionsStreamProvider = StreamProvider<List<Collection>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUserCollections();
});

final collectionWordsStreamProvider = StreamProvider.family<List<SavedWord>, int>((ref, collectionId) {
  final db = ref.watch(databaseProvider);
  return db.watchWordsForCollection(collectionId);
});

final collectionIdsForWordStreamProvider = StreamProvider.family<List<int>, int>((ref, savedWordId) {
  final db = ref.watch(databaseProvider);
  return db.watchCollectionIdsForWord(savedWordId);
});

// Recent Searches Provider
final recentSearchesStreamProvider = StreamProvider<List<String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentSearches();
});
