import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/database/database.dart';

class OfflineDictionaryService {
  final AppDatabase _db;

  OfflineDictionaryService(this._db);

  /// Ensures pre-indexed database is initialized.
  Future<void> autoSyncIfNeeded() async {
    try {
      final count = await _db.getOfflineWordsCount();
      if (count < 1000) {
        await restoreFromBundledAsset();
      }
    } catch (_) {}
  }

  /// Restores the pre-indexed SQLite database directly from bundled asset 'assets/offline_dictionary.db.gz'.
  Future<int> restoreFromBundledAsset() async {
    try {
      final blob = await rootBundle.load('assets/offline_dictionary.db.gz');
      final compressedBytes = blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes);
      final decompressedBytes = GZipCodec().decode(compressedBytes);

      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'dictionary_v2.sqlite'));

      await file.writeAsBytes(decompressedBytes, flush: true);
      return await _db.getOfflineWordsCount();
    } catch (_) {
      return 0;
    }
  }
}
