import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ImportedFileResult {
  final String fileName;
  final String content;
  final String extension;

  const ImportedFileResult({
    required this.fileName,
    required this.content,
    required this.extension,
  });
}

class FileImportService {
  /// Opens native OS file picker to select vocabulary backup files (.json, .csv, .txt).
  static Future<ImportedFileResult?> pickAndReadBackupFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv', 'txt'],
      );

      if (file == null) return null;

      String content = '';

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes);
      }

      final ext = file.extension?.toLowerCase() ?? 'txt';

      return ImportedFileResult(
        fileName: file.name,
        content: content.trim(),
        extension: ext,
      );
    } catch (e) {
      debugPrint('Error picking backup file: $e');
      return null;
    }
  }

  /// Opens native OS file picker to select text documents or books (.txt, .md).
  static Future<ImportedFileResult?> pickAndReadDocumentFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'json'],
      );

      if (file == null) return null;

      String content = '';

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        final bytes = await file.readAsBytes();
        content = utf8.decode(bytes);
      }

      final ext = file.extension?.toLowerCase() ?? 'txt';

      return ImportedFileResult(
        fileName: file.name,
        content: content.trim(),
        extension: ext,
      );
    } catch (e) {
      debugPrint('Error picking document file: $e');
      return null;
    }
  }
}
