import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get pronunciation => text().nullable()();
  TextColumn get cefr => text().nullable()();
  TextColumn get partOfSpeech => text().nullable()();
}

class Definitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  TextColumn get meaning => text()();
  TextColumn get simpleEnglish => text().nullable()();
}

class Examples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get definitionId => integer().references(Definitions, #id)();
  TextColumn get sentence => text()();
}

class SavedWords extends Table {
  IntColumn get wordId => integer().references(Words, #id)();
  DateTimeColumn get dateAdded => dateTime()();
  TextColumn get contextSentence => text().nullable()();
  TextColumn get personalNote => text().nullable()();
  IntColumn get reviewState => integer().withDefault(const Constant(0))(); 
  
  @override
  Set<Column> get primaryKey => {wordId};
}

@DriftDatabase(tables: [Words, Definitions, Examples, SavedWords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  // Future implementation of migrations and queries
  Future<List<Word>> getAllWords() => select(words).get();
  
  Future<List<Word>> searchWords(String query) {
    return (select(words)..where((t) => t.word.like('%$query%'))).get();
  }

  Future<void> seedDatabase() async {
    final count = await select(words).get().then((v) => v.length);
    if (count == 0) {
      final wordId = await into(words).insert(WordsCompanion(
        word: const Value('reluctant'),
        pronunciation: const Value('/ rɪˈlʌktənt /'),
        cefr: const Value('B2'),
        partOfSpeech: const Value('adjective'),
      ));

      final defId = await into(definitions).insert(DefinitionsCompanion(
        wordId: Value(wordId),
        meaning: const Value('Not wanting to do something.'),
        simpleEnglish: const Value('You don\'t really want to do it, but you may do it anyway.'),
      ));

      await into(examples).insert(ExamplesCompanion(
        definitionId: Value(defId),
        sentence: const Value('She was reluctant to leave.'),
      ));

      // Add a few more words
      await into(words).insert(WordsCompanion(
        word: const Value('bohemian'),
        pronunciation: const Value('/ boʊˈhiːmiən /'),
        cefr: const Value('C1'),
        partOfSpeech: const Value('noun'),
      ));

      await into(words).insert(WordsCompanion(
        word: const Value('ephemeral'),
        pronunciation: const Value('/ ɪˈfɛmərəl /'),
        cefr: const Value('C2'),
        partOfSpeech: const Value('adjective'),
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'lexi_lens.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
