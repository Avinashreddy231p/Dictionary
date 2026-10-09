import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/lexical_entry.dart';
import '../providers.dart';

final wordOfTheDayProvider = FutureProvider<LexicalEntry?>((ref) async {
  final db = ref.watch(databaseProvider);
  final repo = ref.watch(wordRepositoryProvider);

  final now = DateTime.now();
  final dateKey = 'wotd_date_${now.year}_${now.month}_${now.day}';
  final prefs = await SharedPreferences.getInstance();

  String? cachedWord = prefs.getString(dateKey);

  if (cachedWord != null && cachedWord.isNotEmpty) {
    final entry = await db.getOfflineWord(cachedWord);
    if (entry != null) return entry;
  }

  // Pick word deterministically based on day of year
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final count = await db.getOfflineWordsCount();

  if (count == 0) {
    // Fallback seed word if offline DB is still initializing
    return LexicalEntry(
      core: CoreData(
        headword: 'ephemeral',
        homograph: 0,
        partOfSpeech: 'adjective',
        phonetic: '/ ɪˈfɛmərəl /',
        audioUrl: '',
        syllables: ['e', 'phem', 'er', 'al'],
      ),
      senses: [
        Sense(
          senseNumber: '1',
          definition: 'Lasting for a very short time; fleeting; transitory.',
          examples: ['Fame in the digital age is often ephemeral.'],
          labels: ['C2', 'vocabulary'],
        )
      ],
      grammar: GrammarData(verbDivision: '', usageNotes: [], inflections: [], relatedForms: []),
      linguistic: LinguisticData(etymology: 'Greek ephemeros', firstKnownUse: '16th century'),
      dictionaryLayer: DictionaryLayer(
        simpleMeaning: 'Lasting for a very short time; fleeting.',
        contextualMeaning: 'Fleeting beauty or fame.',
        synonyms: ['fleeting', 'transitory', 'transient', 'momentary'],
        antonyms: ['permanent', 'eternal', 'everlasting'],
      ),
    );
  }

  final offset = dayOfYear % count;

  final selectedRow = await (db.select(db.words)..limit(1, offset: offset)).getSingleOrNull();

  if (selectedRow != null) {
    final wordText = selectedRow.word;
    await prefs.setString(dateKey, wordText);
    final entry = await db.getOfflineWord(wordText);
    if (entry != null) return entry;
  }

  // Fallback to searching word 'ephemeral' or 'reluctant'
  final fallbackResults = await repo.searchWord('ephemeral');
  return fallbackResults.isNotEmpty ? fallbackResults.first : null;
});
