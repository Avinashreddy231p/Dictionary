import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/database/database.dart';

class OfflineDictionaryService {
  final AppDatabase _db;
  static const String datasetCsvUrl =
      'https://raw.githubusercontent.com/benjihillard/English-Dictionary-Database/refs/heads/main/english%20Dictionary.csv';

  OfflineDictionaryService(this._db);

  /// Downloads the full English Dictionary CSV dataset from GitHub and syncs it to the local SQLite database.
  Future<int> downloadAndSyncDatabase({
    void Function(double progress)? onProgress,
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
    void Function(double progress)? onProgress,
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
