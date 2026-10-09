import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/database/database.dart';

class OfflineDictionaryService {
  final AppDatabase _db;

  OfflineDictionaryService(this._db);

  /// Ensures pre-indexed database is initialized.
  Future<void> autoSyncIfNeeded({
    void Function(double progress, int count)? onProgress,
  }) async {
    try {
      final count = await _db.getOfflineWordsCount();
      if (count < 1000) {
        onProgress?.call(0.1, count);
        await restoreFromBundledAsset();
        final finalCount = await _db.getOfflineWordsCount();
        onProgress?.call(1.0, finalCount);
      } else {
        onProgress?.call(1.0, count);
      }
    } catch (_) {
      onProgress?.call(1.0, 0);
    }
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
