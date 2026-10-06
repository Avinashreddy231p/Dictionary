import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../../core/database/database.dart';

class OfflineDictionaryService {
  final AppDatabase _db;
  static const String datasetCsvUrl =
      'https://raw.githubusercontent.com/benjihillard/English-Dictionary-Database/refs/heads/main/english%20Dictionary.csv';

  OfflineDictionaryService(this._db);

  /// Automatically syncs the offline database from local CSV file or asset if count is low (< 1000).
  Future<void> autoSyncIfNeeded({
    void Function(double progress, int count)? onProgress,
  }) async {
    try {
      final count = await _db.getOfflineWordsCount();
      if (count < 1000) {
        await syncFromLocalOrRemote(onProgress: onProgress);
      }
    } catch (_) {}
  }

  /// Attempts to load and index the dataset from local disk, Flutter assets, or HTTP download.
  Future<int> syncFromLocalOrRemote({
    void Function(double progress, int count)? onProgress,
  }) async {
    // 1. Check local disk paths (e.g. english Dictionary.csv)
    final candidatePaths = [
      'english Dictionary.csv',
      'C:/Users/Avina/Music/Projects/Dictionary/english Dictionary.csv',
      p.join(Directory.current.path, 'english Dictionary.csv'),
    ];

    for (final path in candidatePaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            return await importCsvString(content, onProgress: onProgress);
          }
        }
      } catch (_) {}
    }

    // 2. Check Flutter Asset Bundle
    try {
      final assetContent = await rootBundle.loadString('english Dictionary.csv');
      if (assetContent.isNotEmpty) {
        return await importCsvString(assetContent, onProgress: onProgress);
      }
    } catch (_) {}

    // 3. Fallback to HTTP download
    return await downloadAndSyncDatabase(onProgress: onProgress);
  }

  /// Downloads the full English Dictionary CSV dataset from GitHub and syncs it to the local SQLite database.
  Future<int> downloadAndSyncDatabase({
    void Function(double progress, int count)? onProgress,
  }) async {
    final response = await http.get(Uri.parse(datasetCsvUrl));
    if (response.statusCode == 200) {
      return await importCsvString(response.body, onProgress: onProgress);
    } else {
      throw Exception('Failed to download dataset (HTTP ${response.statusCode})');
    }
  }

  /// Parses CSV dataset text and batch-inserts words and definitions into the database.
  Future<int> importCsvString(
    String csvData, {
    void Function(double progress, int count)? onProgress,
  }) async {
    final lines = const LineSplitter().convert(csvData);
    if (lines.isEmpty) return 0;

    final entries = <({String word, String? pos, String definition})>[];

    // Skip header line [word, pos, definition]
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parsed = _parseCsvLine(line);
      if (parsed != null) {
        entries.add(parsed);
      }
    }

    if (entries.isEmpty) return 0;

    return await _db.batchInsertOfflineWords(entries, onProgress: onProgress);
  }

  /// Robust CSV line parser for [word, pos, definition] respecting quoted fields.
  ({String word, String? pos, String definition})? _parseCsvLine(String line) {
    final fields = <String>[];
    final sb = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          sb.write('"');
          i++; // skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        fields.add(sb.toString().trim());
        sb.clear();
      } else {
        sb.write(char);
      }
    }
    fields.add(sb.toString().trim());

    if (fields.length < 3) return null;

    final word = _cleanQuotes(fields[0]);
    final pos = _cleanQuotes(fields[1]);
    final def = _cleanQuotes(fields[2]);

    if (word.isEmpty || def.isEmpty) return null;

    return (
      word: word,
      pos: pos.isNotEmpty ? pos : null,
      definition: def,
    );
  }

  String _cleanQuotes(String input) {
    String str = input.trim();
    if (str.startsWith('"') && str.endsWith('"') && str.length >= 2) {
      str = str.substring(1, str.length - 1).replaceAll('""', '"').trim();
    }
    return str;
  }
}
