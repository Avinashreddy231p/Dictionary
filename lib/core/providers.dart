import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import '../data/repositories/word_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WordRepository(db);
});
