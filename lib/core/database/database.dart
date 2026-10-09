import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/models/lexical_entry.dart';
import '../utils/fuzzy_search.dart';

part 'database.g.dart';

enum RestoreStrategy { replaceAll, mergeUpdate, mergeSkip }

// --- Drift Database Tables ---

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().unique()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get partOfSpeech => text().nullable()();
  TextColumn get syllables => text().nullable()();
  TextColumn get cefr => text().nullable()();
  TextColumn get etymology => text().nullable()();
  TextColumn get firstKnownUse => text().nullable()();
  TextColumn get simpleMeaning => text().nullable()();
  TextColumn get contextualMeaning => text().nullable()();
}

class Definitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id, onDelete: KeyAction.cascade)();
  TextColumn get senseNumber => text().nullable()();
  TextColumn get definition => text()();
  TextColumn get labels => text().nullable()(); // comma separated e.g. "archaic, formal"
}

class Examples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get definitionId => integer().references(Definitions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exampleText => text()();
}

class SavedWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().unique()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get partOfSpeech => text().nullable()();
  TextColumn get meaning => text().nullable()();
  TextColumn get example => text().nullable()();
  TextColumn get syllables => text().nullable()();
  TextColumn get cefr => text().nullable()();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get contextSentence => text().nullable()();
  TextColumn get personalNote => text().nullable()();
  IntColumn get reviewState => integer().withDefault(const Constant(0))(); // 0 = Learning, 1 = Review, 2 = Known
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get source => text().nullable()();
}

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get colorHex => text().withDefault(const Constant('0xFFE5D4FF'))();
  TextColumn get iconName => text().nullable()();
  TextColumn get tags => text().nullable()(); // Comma-separated tags e.g. "IELTS, Exam"
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();
  TextColumn get smartType => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class CollectionWords extends Table {
  IntColumn get collectionId => integer().references(Collections, #id, onDelete: KeyAction.cascade)();
  IntColumn get savedWordId => integer().references(SavedWords, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {collectionId, savedWordId};
}

class RecentSearches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text().unique()();
  DateTimeColumn get searchedAt => dateTime()();
}

@DriftDatabase(tables: [Words, Definitions, Examples, SavedWords, Collections, CollectionWords, RecentSearches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.addColumn(collections, collections.tags);
      }
    },
  );

  // --- Saved Words Queries & Streams ---
  Stream<List<SavedWord>> watchAllSavedWords() {
    return (select(savedWords)..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Stream<List<SavedWord>> watchTodaySavedWords() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (select(savedWords)
      ..where((t) => t.dateAdded.isBiggerOrEqualValue(startOfDay))
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Stream<List<SavedWord>> watchRecentSavedWords({int limit = 10}) {
    return (select(savedWords)
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])
      ..limit(limit)).watch();
  }

  Stream<List<SavedWord>> watchFavorites() {
    return (select(savedWords)
      ..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Stream<List<SavedWord>> watchNeedsReview() {
    return (select(savedWords)
      ..where((t) => t.reviewState.isIn([0, 1]))
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Stream<List<SavedWord>> watchWordsWithSource() {
    return (select(savedWords)
      ..where((t) => t.source.isNotNull() & t.source.isNotValue(''))
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Stream<List<SavedWord>> watchMasteredWords() {
    return (select(savedWords)
      ..where((t) => t.reviewState.equals(2))
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Stream<List<SavedWord>> watchWordsWithNotes() {
    return (select(savedWords)
      ..where((t) => (t.contextSentence.isNotNull() & t.contextSentence.isNotValue('')) | (t.personalNote.isNotNull() & t.personalNote.isNotValue('')))
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])).watch();
  }

  Future<SavedWord?> getSavedWordByWord(String word) {
    return (select(savedWords)..where((t) => t.word.equals(word.toLowerCase()))).getSingleOrNull();
  }

  Future<List<SavedWord>> searchSavedWordsFuzzy(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final allSaved = await select(savedWords).get();
    final matches = FuzzySearch.rankMatches<SavedWord>(
      query: cleanQuery,
      candidates: allSaved,
      wordExtractor: (w) => w.word,
      minSimilarity: 0.40,
    );

    return matches.map((m) => m.item).toList();
  }

  Stream<SavedWord?> watchSavedWordByWord(String word) {
    return (select(savedWords)..where((t) => t.word.equals(word.toLowerCase()))).watchSingleOrNull();
  }

  Future<int> saveWord({
    required String word,
    String? phonetic,
    String? partOfSpeech,
    String? meaning,
    String? example,
    String? syllables,
    String? cefr,
    String? contextSentence,
    String? personalNote,
    String? source,
    int reviewState = 0,
    bool isFavorite = false,
  }) async {
    final existing = await getSavedWordByWord(word);
    if (existing != null) {
      return existing.id;
    }
    return into(savedWords).insert(SavedWordsCompanion.insert(
      word: word.toLowerCase(),
      phonetic: Value(phonetic),
      partOfSpeech: Value(partOfSpeech),
      meaning: Value(meaning),
      example: Value(example),
      syllables: Value(syllables),
      cefr: Value(cefr),
      dateAdded: DateTime.now(),
      contextSentence: Value(contextSentence),
      personalNote: Value(personalNote),
      source: Value(source),
      reviewState: Value(reviewState),
      isFavorite: Value(isFavorite),
    ));
  }

  Future<int> batchSaveWords(List<SavedWordsCompanion> companions) async {
    int inserted = 0;
    await transaction(() async {
      for (final c in companions) {
        final wordStr = c.word.value.toLowerCase();
        final existing = await getSavedWordByWord(wordStr);
        if (existing == null) {
          await into(savedWords).insert(c, mode: InsertMode.insertOrReplace);
          inserted++;
        }
      }
    });
    return inserted;
  }

  Future<int> batchSaveWordsAndAddToCollection(
    List<SavedWordsCompanion> companions,
    int collectionId,
  ) async {
    int inserted = 0;
    await transaction(() async {
      for (final c in companions) {
        final wordStr = c.word.value.toLowerCase();
        var existing = await getSavedWordByWord(wordStr);
        int savedWordId;
        if (existing == null) {
          savedWordId = await into(savedWords).insert(c, mode: InsertMode.insertOrReplace);
          inserted++;
        } else {
          savedWordId = existing.id;
        }

        if (savedWordId > 0) {
          await addWordToCollection(collectionId, savedWordId);
        }
      }
    });
    return inserted;
  }

  Future<void> updatePersonalNote(int savedWordId, String note) async {
    await (update(savedWords)..where((t) => t.id.equals(savedWordId))).write(
      SavedWordsCompanion(personalNote: Value(note)),
    );
  }

  Future<void> removeSavedWord(String word) async {
    await (delete(savedWords)..where((t) => t.word.equals(word.toLowerCase()))).go();
  }

  Future<void> toggleFavorite(int savedWordId) async {
    final word = await (select(savedWords)..where((t) => t.id.equals(savedWordId))).getSingleOrNull();
    if (word != null) {
      await (update(savedWords)..where((t) => t.id.equals(savedWordId))).write(
        SavedWordsCompanion(isFavorite: Value(!word.isFavorite)),
      );
    }
  }

  Future<void> updateReviewState(int savedWordId, int state) async {
    await (update(savedWords)..where((t) => t.id.equals(savedWordId))).write(
      SavedWordsCompanion(reviewState: Value(state)),
    );
  }

  // --- Collections Queries & Streams ---
  Stream<List<Collection>> watchUserCollections() {
    return (select(collections)
      ..where((t) => t.isSmart.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<List<SavedWord>> watchWordsForCollection(int collectionId) {
    final query = select(savedWords).join([
      innerJoin(collectionWords, collectionWords.savedWordId.equalsExp(savedWords.id)),
    ])..where(collectionWords.collectionId.equals(collectionId));

    return query.watch().map((rows) => rows.map((row) => row.readTable(savedWords)).toList());
  }

  Stream<List<int>> watchCollectionIdsForWord(int savedWordId) {
    final query = select(collectionWords)..where((t) => t.savedWordId.equals(savedWordId));
    return query.watch().map((rows) => rows.map((r) => r.collectionId).toList());
  }

  Future<int> createCollection({
    required String title,
    String? description,
    String? colorHex,
    String? iconName,
    String? tags,
  }) async {
    final cleanTitle = title.trim();
    final existing = await (select(collections)..where((t) => t.title.lower().equals(cleanTitle.toLowerCase()))).get();
    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    return into(collections).insert(CollectionsCompanion.insert(
      title: cleanTitle,
      description: Value(description),
      colorHex: Value(colorHex ?? '0xFFE5D4FF'),
      iconName: Value(iconName ?? 'book'),
      tags: Value(tags),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> updateCollection({
    required int id,
    required String title,
    String? description,
    String? colorHex,
    String? iconName,
    String? tags,
  }) async {
    await (update(collections)..where((t) => t.id.equals(id))).write(
      CollectionsCompanion(
        title: Value(title),
        description: Value(description),
        colorHex: Value(colorHex ?? '0xFFE5D4FF'),
        iconName: Value(iconName ?? 'book'),
        tags: Value(tags),
      ),
    );
  }

  Future<void> deleteCollection(int collectionId) async {
    await (delete(collectionWords)..where((t) => t.collectionId.equals(collectionId))).go();
    await (delete(collections)..where((t) => t.id.equals(collectionId))).go();
  }

  Future<void> addWordToCollection(int collectionId, int savedWordId) async {
    await into(collectionWords).insertOnConflictUpdate(CollectionWordsCompanion.insert(
      collectionId: collectionId,
      savedWordId: savedWordId,
      addedAt: DateTime.now(),
    ));
  }

  Future<void> removeWordFromCollection(int collectionId, int savedWordId) async {
    await (delete(collectionWords)
      ..where((t) => t.collectionId.equals(collectionId) & t.savedWordId.equals(savedWordId))).go();
  }

  // --- Recent Searches & Visited Words ---
  Stream<List<String>> watchRecentSearches({int limit = 10}) {
    return (select(recentSearches)
      ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
      ..limit(limit))
      .watch()
      .map((list) => list.map((item) => item.query).toList());
  }

  Stream<List<SavedWord>> watchVisitedWords() {
    final query = select(recentSearches).join([
      leftOuterJoin(savedWords, savedWords.word.equalsExp(recentSearches.query.lower())),
      leftOuterJoin(words, words.word.equalsExp(recentSearches.query.lower())),
    ])..orderBy([OrderingTerm.desc(recentSearches.searchedAt)]);

    return query.watch().map((rows) {
      final List<SavedWord> list = [];
      for (final row in rows) {
        final saved = row.readTableOrNull(savedWords);
        final recent = row.readTable(recentSearches);
        if (saved != null) {
          list.add(saved);
        } else {
          final dictWord = row.readTableOrNull(words);
          list.add(
            SavedWord(
              id: -recent.id,
              word: recent.query,
              partOfSpeech: dictWord?.partOfSpeech ?? 'noun',
              phonetic: dictWord?.phonetic ?? '',
              meaning: dictWord?.simpleMeaning ?? 'Visited in dictionary',
              example: null,
              contextSentence: null,
              personalNote: null,
              source: 'Search History',
              isFavorite: false,
              reviewState: 0,
              dateAdded: recent.searchedAt,
            ),
          );
        }
      }
      return list;
    });
  }

  Future<void> addRecentSearch(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return;
    await into(recentSearches).insertOnConflictUpdate(RecentSearchesCompanion.insert(
      query: cleanQuery,
      searchedAt: DateTime.now(),
    ));
  }

  Future<void> clearRecentSearches() async {
    await delete(recentSearches).go();
  }

  // --- Export & Restore Methods ---
  Future<Map<String, dynamic>> exportUserDatabase({
    bool includeWords = true,
    bool includeCollections = true,
    bool includeHistory = true,
    void Function(double, String)? onProgress,
  }) async {
    final Map<String, dynamic> data = {};

    if (includeWords) {
      onProgress?.call(0.1, 'Exporting Vocabulary...');
      final wordsList = await select(savedWords).get();
      data['savedWords'] = wordsList.map((w) => w.toJson()).toList();
    }

    if (includeCollections) {
      onProgress?.call(0.3, 'Exporting Collections...');
      final cols = await select(collections).get();
      data['collections'] = cols.map((c) => c.toJson()).toList();

      onProgress?.call(0.5, 'Exporting Collection Links...');
      final links = await select(collectionWords).get();
      data['collectionWords'] = links.map((l) => l.toJson()).toList();
    }

    if (includeHistory) {
      onProgress?.call(0.7, 'Exporting History...');
      final searches = await select(recentSearches).get();
      data['recentSearches'] = searches.map((s) => s.toJson()).toList();
    }

    onProgress?.call(1.0, 'Database Export Complete');
    return data;
  }

  Future<void> restoreUserDatabase(
    Map<String, dynamic> data, {
    RestoreStrategy wordStrategy = RestoreStrategy.mergeSkip,
    RestoreStrategy collectionStrategy = RestoreStrategy.mergeSkip,
    RestoreStrategy historyStrategy = RestoreStrategy.mergeSkip,
    void Function(double, String)? onProgress,
  }) async {
    await transaction(() async {
      // 1. Vocabulary Restore
      if (data.containsKey('savedWords')) {
        onProgress?.call(0.1, 'Restoring Vocabulary...');
        final list = data['savedWords'] as List<dynamic>;
        
        if (wordStrategy == RestoreStrategy.replaceAll) {
          await delete(savedWords).go();
        }

        int count = 0;
        for (final item in list) {
          final word = SavedWord.fromJson(item as Map<String, dynamic>);
          final comp = word.toCompanion(false);
          final existing = await getSavedWordByWord(word.word);
          
          if (wordStrategy == RestoreStrategy.replaceAll) {
             await into(savedWords).insert(comp.copyWith(id: const Value.absent()), mode: InsertMode.insertOrReplace);
          } else if (wordStrategy == RestoreStrategy.mergeUpdate) {
             if (existing != null) {
               await update(savedWords).replace(comp.copyWith(id: Value(existing.id)));
             } else {
               await into(savedWords).insert(comp.copyWith(id: const Value.absent()));
             }
          } else if (wordStrategy == RestoreStrategy.mergeSkip) {
             if (existing == null) {
               await into(savedWords).insert(comp.copyWith(id: const Value.absent()));
             }
          }
          count++;
          if (count % 50 == 0) {
            onProgress?.call(0.1 + (0.3 * (count / list.length)), 'Restored $count words...');
          }
        }
      }

      // 2. Collections Restore
      if (data.containsKey('collections') && data.containsKey('collectionWords')) {
        onProgress?.call(0.4, 'Restoring Collections...');
        final colList = data['collections'] as List<dynamic>;
        final linksList = data['collectionWords'] as List<dynamic>;

        if (collectionStrategy == RestoreStrategy.replaceAll) {
          await delete(collectionWords).go();
          await delete(collections).go();
        }

        // Keep track of old to new collection IDs for links mapping
        final colIdMap = <int, int>{};
        
        int count = 0;
        for (final item in colList) {
          final col = Collection.fromJson(item as Map<String, dynamic>);
          final comp = col.toCompanion(false);
          final existingQuery = await (select(collections)..where((t) => t.title.lower().equals(col.title.toLowerCase()))).getSingleOrNull();
          
          int newId = -1;
          if (collectionStrategy == RestoreStrategy.replaceAll) {
             newId = await into(collections).insert(comp.copyWith(id: const Value.absent()));
          } else if (collectionStrategy == RestoreStrategy.mergeUpdate) {
             if (existingQuery != null) {
                await update(collections).replace(comp.copyWith(id: Value(existingQuery.id)));
                newId = existingQuery.id;
             } else {
                newId = await into(collections).insert(comp.copyWith(id: const Value.absent()));
             }
          } else if (collectionStrategy == RestoreStrategy.mergeSkip) {
             if (existingQuery == null) {
                newId = await into(collections).insert(comp.copyWith(id: const Value.absent()));
             } else {
                newId = existingQuery.id;
             }
          }
          
          if (newId != -1) {
             colIdMap[col.id] = newId;
          }
          count++;
        }

        onProgress?.call(0.6, 'Restoring Collection Links...');
        for (final item in linksList) {
          final link = CollectionWord.fromJson(item as Map<String, dynamic>);
          
          // Map to new collection ID
          final targetColId = colIdMap[link.collectionId];
          if (targetColId == null) continue;
          
          // Only link words that currently exist in the database (since word IDs may have shifted or skipped)
          final originalSavedWordId = link.savedWordId;
          // In a robust system, we would need to map word IDs based on headword match.
          // Since we didn't map word IDs, we must query the word by headword from the backup JSON to find the new local ID.
          // This requires us to look back at data['savedWords'].
          
          final savedWordsList = data['savedWords'] as List<dynamic>? ?? [];
          final backupWordData = savedWordsList.firstWhere(
            (w) => w['id'] == originalSavedWordId, 
            orElse: () => null
          );
          
          if (backupWordData != null) {
             final headword = backupWordData['word'] as String;
             final currentWordRecord = await getSavedWordByWord(headword);
             if (currentWordRecord != null) {
                await into(collectionWords).insertOnConflictUpdate(
                  CollectionWordsCompanion.insert(
                    collectionId: targetColId,
                    savedWordId: currentWordRecord.id,
                    addedAt: link.addedAt,
                  ),
                );
             }
          }
        }
      }

      // 3. History Restore
      if (data.containsKey('recentSearches')) {
        onProgress?.call(0.8, 'Restoring Search History...');
        final historyList = data['recentSearches'] as List<dynamic>;

        if (historyStrategy == RestoreStrategy.replaceAll) {
          await delete(recentSearches).go();
        }

        for (final item in historyList) {
          final search = RecentSearche.fromJson(item as Map<String, dynamic>);
          final comp = search.toCompanion(false);
          final existing = await (select(recentSearches)..where((t) => t.query.equals(search.query))).getSingleOrNull();

          if (historyStrategy == RestoreStrategy.replaceAll) {
             await into(recentSearches).insert(comp.copyWith(id: const Value.absent()));
          } else if (historyStrategy == RestoreStrategy.mergeUpdate) {
             if (existing != null) {
               await update(recentSearches).replace(comp.copyWith(id: Value(existing.id)));
             } else {
               await into(recentSearches).insert(comp.copyWith(id: const Value.absent()));
             }
          } else if (historyStrategy == RestoreStrategy.mergeSkip) {
             if (existing == null) {
               await into(recentSearches).insert(comp.copyWith(id: const Value.absent()));
             }
          }
        }
      }
      
      onProgress?.call(1.0, 'Database Restore Complete');
    });
  }

  // --- Offline Backup Dictionary Queries & Utilities ---
  Future<LexicalEntry?> getOfflineWord(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return null;

    // 1. Case-insensitive exact match or headword variant match (e.g. "Run", "run", "run, v.", "run.")
    List<Word> wordRows = await (select(words)
      ..where((t) =>
          t.word.lower().equals(cleanQuery) |
          t.word.like(cleanQuery) |
          t.word.like('$cleanQuery,%') |
          t.word.like('$cleanQuery.%'))
      ..limit(10)).get();

    // 2. Substring match fallback
    if (wordRows.isEmpty) {
      wordRows = await (select(words)
        ..where((t) => t.word.like('%$cleanQuery%'))
        ..limit(5)).get();
    }

    if (wordRows.isEmpty) return null;

    final primaryWord = wordRows.first;

    // Aggregate senses across all matching rows
    final List<Sense> allSenses = [];
    for (final wRow in wordRows) {
      final defRows = await (select(definitions)..where((t) => t.wordId.equals(wRow.id))).get();
      for (final d in defRows) {
        allSenses.add(Sense(
          senseNumber: d.senseNumber ?? '${allSenses.length + 1}',
          definition: d.definition,
          examples: [],
          labels: d.labels?.split(',').map((e) => e.trim()).toList() ?? [],
        ));
      }
      if (wRow.simpleMeaning != null && wRow.simpleMeaning!.isNotEmpty) {
        if (!allSenses.any((s) => s.definition == wRow.simpleMeaning)) {
          allSenses.add(Sense(
            senseNumber: '${allSenses.length + 1}',
            definition: wRow.simpleMeaning!,
            examples: [],
            labels: [],
          ));
        }
      }
    }

    final mainDef = allSenses.isNotEmpty ? allSenses.first.definition : (primaryWord.simpleMeaning ?? 'No offline definition available.');

    return LexicalEntry(
      core: CoreData(
        headword: primaryWord.word,
        homograph: 0,
        partOfSpeech: primaryWord.partOfSpeech ?? 'word',
        phonetic: primaryWord.phonetic ?? '',
        audioUrl: '',
        syllables: primaryWord.syllables?.split('*') ?? [primaryWord.word],
      ),
      senses: allSenses.isNotEmpty
          ? allSenses
          : [
              Sense(
                senseNumber: '1',
                definition: mainDef,
                examples: [],
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
        etymology: primaryWord.etymology ?? 'English Dictionary',
        firstKnownUse: primaryWord.firstKnownUse ?? '',
      ),
      dictionaryLayer: DictionaryLayer(
        simpleMeaning: mainDef,
        contextualMeaning: primaryWord.contextualMeaning ?? 'Offline backup dictionary definition.',
        synonyms: [],
        antonyms: [],
      ),
    );
  }

  Future<List<LexicalEntry>> searchOfflineWordsFuzzy(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final Map<String, String> candidateWords = {};

    // 1. Direct prefix / substring matches in CSV Words table
    final directRows = await (select(words)
      ..where((t) => t.word.like('$cleanQuery%') | t.word.like('%$cleanQuery%'))
      ..limit(30)).get();

    for (final r in directRows) {
      candidateWords[r.word.toLowerCase()] = r.word;
    }

    // 2. Misspelling candidate retrieval for typos (shares first letter & similar length)
    if (candidateWords.length < 15 && cleanQuery.length >= 2) {
      final firstLetter = cleanQuery[0];
      final minLen = (cleanQuery.length - 2).clamp(1, 100);
      final maxLen = cleanQuery.length + 3;

      final typoRows = await (select(words)
        ..where((t) => t.word.like('$firstLetter%') & t.word.length.isBetweenValues(minLen, maxLen))
        ..limit(100)).get();

      for (final r in typoRows) {
        candidateWords[r.word.toLowerCase()] = r.word;
      }
    }

    if (candidateWords.isEmpty) return [];

    // 3. Rank candidates using FuzzySearch (Levenshtein distance & similarity)
    final matches = FuzzySearch.rankMatches<String>(
      query: cleanQuery,
      candidates: candidateWords.keys.toList(),
      wordExtractor: (s) => s,
      minSimilarity: 0.25,
      maxResults: 8,
    );

    final results = <LexicalEntry>[];
    for (final match in matches) {
      final headword = candidateWords[match.item];
      if (headword != null) {
        final entry = await getOfflineWord(headword);
        if (entry != null) results.add(entry);
      }
    }
    return results;
  }

  Future<List<String>> getOfflineSuggestions(String query, {int limit = 5}) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final Map<String, String> candidateMap = {};

    // 1. Gather prefix candidates from CSV Words table (starts with cleanQuery)
    final prefixWords = await (select(words)
      ..where((t) => t.word.like('$cleanQuery%'))
      ..limit(40)).get();

    for (final w in prefixWords) {
      candidateMap[w.word.toLowerCase()] = w.word;
    }

    // 2. Gather prefix candidates from SavedWords table
    final prefixSaved = await (select(savedWords)
      ..where((t) => t.word.like('$cleanQuery%'))
      ..limit(20)).get();

    for (final s in prefixSaved) {
      candidateMap[s.word.toLowerCase()] = s.word;
    }

    // 3. Gather substring candidates from CSV Words table (%cleanQuery%)
    if (candidateMap.length < 30) {
      final subWords = await (select(words)
        ..where((t) => t.word.like('%$cleanQuery%'))
        ..limit(50)).get();

      for (final w in subWords) {
        if (!candidateMap.containsKey(w.word.toLowerCase())) {
          candidateMap[w.word.toLowerCase()] = w.word;
        }
      }
    }

    // 4. Misspelling candidate retrieval for typos
    if (candidateMap.length < 15 && cleanQuery.length >= 2) {
      final firstLetter = cleanQuery[0];
      final minLen = (cleanQuery.length - 2).clamp(1, 100);
      final maxLen = cleanQuery.length + 3;

      final typoWords = await (select(words)
        ..where((t) => t.word.like('$firstLetter%') & t.word.length.isBetweenValues(minLen, maxLen))
        ..limit(100)).get();

      for (final w in typoWords) {
        if (!candidateMap.containsKey(w.word.toLowerCase())) {
          candidateMap[w.word.toLowerCase()] = w.word;
        }
      }
    }

    if (candidateMap.isEmpty) return [];

    // 5. Perform Fuzzy Ranking across CSV dictionary and local words
    final matches = FuzzySearch.rankMatches<String>(
      query: cleanQuery,
      candidates: candidateMap.keys.toList(),
      wordExtractor: (s) => s,
      minSimilarity: 0.15,
      maxResults: limit,
    );

    final List<String> result = [];
    for (final match in matches) {
      final original = candidateMap[match.item];
      if (original != null && !result.contains(original)) {
        result.add(original);
      }
    }

    for (final displayWord in candidateMap.values) {
      if (!result.contains(displayWord)) {
        result.add(displayWord);
      }
      if (result.length >= limit) break;
    }

    return result.take(limit).toList();
  }

  Future<int> getOfflineWordsCount() async {
    final result = await select(words).get();
    return result.length;
  }

  Stream<int> watchOfflineWordsCount() {
    return select(words).watch().map((list) => list.length);
  }

  Future<int> batchInsertOfflineWords(
    List<({String word, String? pos, String definition})> entries, {
    void Function(double progress, int count)? onProgress,
  }) async {
    int insertedCount = 0;
    const chunkSize = 500;
    final total = entries.length;

    for (int i = 0; i < total; i += chunkSize) {
      final end = (i + chunkSize < total) ? i + chunkSize : total;
      final chunk = entries.sublist(i, end);

      await transaction(() async {
        for (final entry in chunk) {
          final wordClean = entry.word.toLowerCase();

          int wordId = await into(words).insert(
            WordsCompanion.insert(
              word: wordClean,
              partOfSpeech: Value(entry.pos),
              simpleMeaning: Value(entry.definition),
            ),
            mode: InsertMode.insertOrIgnore,
          );

          if (wordId == 0) {
            final existing = await (select(words)..where((t) => t.word.equals(wordClean))).getSingleOrNull();
            wordId = existing?.id ?? 0;
          }

          if (wordId > 0) {
            await into(definitions).insert(
              DefinitionsCompanion.insert(
                wordId: wordId,
                definition: entry.definition,
                senseNumber: const Value('1'),
              ),
              mode: InsertMode.insertOrIgnore,
            );
            insertedCount++;
          }
        }
      });

      if (onProgress != null) {
        onProgress((end / total).clamp(0.0, 1.0), insertedCount);
      }
    }

    return insertedCount;
  }

  // --- Initial Database Seed with rich real data ---
  Future<void> seedDatabase() async {
    final count = await select(savedWords).get().then((v) => v.length);
    if (count == 0) {
      // Seed Collections
      final gatsbyColId = await createCollection(
        title: 'The Great Gatsby',
        description: 'Key vocabulary encountered while reading Chapter 3',
        colorHex: '0xFFE5D4FF',
        iconName: 'book',
        tags: 'Book, Fiction, Classic',
      );
      final forgetColId = await createCollection(
        title: 'Words I Keep Forgetting',
        description: 'Tricky advanced terms needing extra repetition',
        colorHex: '0xFFD4F5E9',
        iconName: 'star',
        tags: 'Tricky, Review, Important',
      );
      final ieltsColId = await createCollection(
        title: 'IELTS Vocabulary',
        description: 'Band 8+ academic words for speaking and writing',
        colorHex: '0xFFFFE2D4',
        iconName: 'flag',
        tags: 'Exam, IELTS, Academic',
      );
      final hpColId = await createCollection(
        title: 'Harry Potter',
        description: 'Magical and literary descriptions',
        colorHex: '0xFFD4E3FF',
        iconName: 'sparkles',
        tags: 'Book, Magic, Literature',
      );

      // Seed Saved Words
      final w1 = await saveWord(
        word: 'reluctant',
        phonetic: '/ rɪˈlʌktənt /',
        partOfSpeech: 'adjective',
        meaning: 'Not wanting to do something; feeling or showing hesitation.',
        example: 'She was reluctant to leave the warm fireplace.',
        syllables: 're*luc*tant',
        cefr: 'B2',
        source: 'The Great Gatsby',
        contextSentence: 'He was reluctant to enter the room, even though he knew it was important.',
        reviewState: 0,
        isFavorite: true,
      );

      final w2 = await saveWord(
        word: 'bohemian',
        phonetic: '/ boʊˈhiːmiən /',
        partOfSpeech: 'noun',
        meaning: 'A person who lives an unconventional, artistic lifestyle.',
        example: 'They lived a bohemian life in Paris during the 1920s.',
        syllables: 'bo*he*mi*an',
        cefr: 'C1',
        source: 'The Great Gatsby',
        contextSentence: 'The party attracted a colorful mix of bohemians and aristocrats.',
        reviewState: 1,
        isFavorite: false,
      );

      final w3 = await saveWord(
        word: 'ephemeral',
        phonetic: '/ ɪˈfɛmərəl /',
        partOfSpeech: 'adjective',
        meaning: 'Lasting for a very short time; fleeting.',
        example: 'Fame in the digital age is often ephemeral.',
        syllables: 'e*phem*er*al',
        cefr: 'C2',
        source: 'Words I Keep Forgetting',
        contextSentence: 'The beauty of the cherry blossoms is poetic precisely because it is ephemeral.',
        reviewState: 0,
        isFavorite: true,
      );

      final w4 = await saveWord(
        word: 'serene',
        phonetic: '/ sɪˈriːn /',
        partOfSpeech: 'adjective',
        meaning: 'Calm, peaceful, and untroubled; tranquil.',
        example: 'The lake was serene in the early morning fog.',
        syllables: 'se*rene',
        cefr: 'B1',
        source: 'IELTS Vocabulary',
        contextSentence: 'Her serene expression reassured everyone in the crowded room.',
        reviewState: 2,
        isFavorite: false,
      );

      final w5 = await saveWord(
        word: 'quintessential',
        phonetic: '/ ˌkwɪntɪˈsɛnʃəl /',
        partOfSpeech: 'adjective',
        meaning: 'Representing the most perfect or typical example of a quality or class.',
        example: 'He was the quintessential tough guy.',
        syllables: 'quin*tes*sen*tial',
        cefr: 'C2',
        source: 'Harry Potter',
        contextSentence: 'It was a quintessential autumn day with crisp crisp air.',
        reviewState: 1,
        isFavorite: true,
      );

      final w6 = await saveWord(
        word: 'resilient',
        phonetic: '/ rɪˈzɪliənt /',
        partOfSpeech: 'adjective',
        meaning: 'Able to withstand or recover quickly from difficult conditions.',
        example: 'Babies are surprisingly resilient.',
        syllables: 're*sil*i*ent',
        cefr: 'B2',
        source: 'IELTS Vocabulary',
        contextSentence: 'The community remained resilient after the storm.',
        reviewState: 2,
        isFavorite: false,
      );

      // Link Words to Collections
      await addWordToCollection(gatsbyColId, w1);
      await addWordToCollection(gatsbyColId, w2);
      await addWordToCollection(forgetColId, w3);
      await addWordToCollection(ieltsColId, w4);
      await addWordToCollection(hpColId, w5);
      await addWordToCollection(ieltsColId, w6);
    }

    // Seed Offline Backup Dictionary starter entries if empty
    final offlineCount = await getOfflineWordsCount();
    if (offlineCount == 0) {
      await batchInsertOfflineWords([
        (word: 'aam', pos: 'n.', definition: 'A Dutch and German measure of liquids, varying in different cities.'),
        (word: 'aardvark', pos: 'n.', definition: 'An African burrowing nocturnal mammal (Orycteropus afer) that feeds on ants and termites.'),
        (word: 'abacus', pos: 'n.', definition: 'An instrument for performing arithmetical calculations by sliding counters along rods.'),
        (word: 'abandon', pos: 'v. t.', definition: 'To give up completely; to desert or forsake.'),
        (word: 'abate', pos: 'v. t.', definition: 'To bring down or reduce from a higher to a lower state, degree, or intensity.'),
        (word: 'ability', pos: 'n.', definition: 'The quality or state of being able; physical, mental, or legal power.'),
        (word: 'able', pos: 'a.', definition: 'Having sufficient power, skill, or resources to accomplish something.'),
        (word: 'absent', pos: 'a.', definition: 'Not present in a place, at an occasion, or as part of something.'),
        (word: 'absorb', pos: 'v. t.', definition: 'To take in or soak up energy, liquid, or other substances.'),
        (word: 'abstract', pos: 'a.', definition: 'Existing in thought or as an idea but not having a physical or concrete existence.'),
        (word: 'academic', pos: 'a.', definition: 'Relating to education, research, or scholarship.'),
        (word: 'accept', pos: 'v. t.', definition: 'To consent to receive or undertake something offered.'),
        (word: 'accurate', pos: 'a.', definition: 'Correct in all details; exact and precise.'),
        (word: 'achieve', pos: 'v. t.', definition: 'To successfully bring about or reach a desired objective by effort.'),
        (word: 'acquire', pos: 'v. t.', definition: 'To buy or obtain an asset, object, or skill for oneself.'),
        (word: 'adapt', pos: 'v.', definition: 'To make suitable to a new use or purpose; modify.'),
        (word: 'adequate', pos: 'a.', definition: 'Satisfactory or acceptable in quality or quantity.'),
        (word: 'aesthetic', pos: 'a.', definition: 'Concerned with beauty or the appreciation of beauty.'),
        (word: 'alleviate', pos: 'v. t.', definition: 'To make suffering, deficiency, or a problem less severe.'),
        (word: 'allocate', pos: 'v. t.', definition: 'To distribute resources or duties for a particular purpose.'),
        (word: 'ambiguous', pos: 'a.', definition: 'Open to more than one interpretation; having a double meaning.'),
        (word: 'analyze', pos: 'v. t.', definition: 'To examine methodically and in detail the constitution or structure.'),
        (word: 'anticipate', pos: 'v. t.', definition: 'To regard as probable; expect or predict.'),
        (word: 'bohemian', pos: 'n.', definition: 'A person who lives an unconventional, artistic lifestyle.'),
        (word: 'ephemeral', pos: 'a.', definition: 'Lasting for a very short time; transitory; fleeting.'),
        (word: 'horse', pos: 'n.', definition: 'A large plant-eating domesticated mammal with solid hooves and a flowing mane and tail.'),
        (word: 'house', pos: 'n.', definition: 'A building for human habitation, especially one that is lived in by a family.'),
        (word: 'human', pos: 'a.', definition: 'Relating to or characteristic of humankind; a person.'),
        (word: 'quintessential', pos: 'a.', definition: 'Representing the most perfect or typical example of a quality or class.'),
        (word: 'reluctant', pos: 'a.', definition: 'Unwilling and hesitant; disinclined to action.'),
        (word: 'resilient', pos: 'a.', definition: 'Able to withstand or recover quickly from difficult conditions.'),
        (word: 'serene', pos: 'a.', definition: 'Calm, peaceful, and untroubled; tranquil.'),
      ]);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dictionary_v2.sqlite'));
    
    bool needsDecompress = !await file.exists();
    if (!needsDecompress) {
      try {
        final length = await file.length();
        if (length < 10000000) {
          needsDecompress = true;
        }
      } catch (_) {}
    }

    if (needsDecompress) {
      try {
        final blob = await rootBundle.load('assets/offline_dictionary.db.gz');
        final compressedBytes = blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes);
        final decompressedBytes = GZipCodec().decode(compressedBytes);
        await file.writeAsBytes(decompressedBytes, flush: true);
      } catch (_) {}
    }
    return NativeDatabase.createInBackground(file);
  });
}
