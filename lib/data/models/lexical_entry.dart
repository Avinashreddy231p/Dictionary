class CoreData {
  final String headword;
  final int homograph;
  final String partOfSpeech;
  final String phonetic;
  final String audioUrl;
  final String ukAudioUrl;
  final List<String> syllables;

  CoreData({
    required this.headword,
    required this.homograph,
    required this.partOfSpeech,
    required this.phonetic,
    required this.audioUrl,
    String? ukAudioUrl,
    required this.syllables,
  }) : ukAudioUrl = ukAudioUrl ??
            'https://api.dictionaryapi.dev/media/pronunciations/en/${headword.toLowerCase()}-uk.mp3';
}

class Sense {
  final String senseNumber; // e.g. "1a", "2"
  final String definition;
  final List<String> examples;
  final List<String> labels; // e.g. "chiefly British"

  Sense({
    required this.senseNumber,
    required this.definition,
    required this.examples,
    required this.labels,
  });
}

class GrammarData {
  final String verbDivision; // "transitive verb", "intransitive verb"
  final List<String> usageNotes; // "often used with out"
  final List<String> inflections; // "tested", "testing"
  final List<String> relatedForms; // "testable", "testability"

  GrammarData({
    required this.verbDivision,
    required this.usageNotes,
    required this.inflections,
    required this.relatedForms,
  });
}

class LinguisticData {
  final String etymology;
  final String firstKnownUse;

  LinguisticData({
    required this.etymology,
    required this.firstKnownUse,
  });
}

class DictionaryLayer {
  final String simpleMeaning;
  final String contextualMeaning;
  final List<String> synonyms;
  final List<String> antonyms;

  DictionaryLayer({
    required this.simpleMeaning,
    required this.contextualMeaning,
    required this.synonyms,
    required this.antonyms,
  });

  DictionaryLayer copyWith({
    String? simpleMeaning,
    String? contextualMeaning,
    List<String>? synonyms,
    List<String>? antonyms,
  }) {
    return DictionaryLayer(
      simpleMeaning: simpleMeaning ?? this.simpleMeaning,
      contextualMeaning: contextualMeaning ?? this.contextualMeaning,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
    );
  }
}

typedef LexiLensLayer = DictionaryLayer;

class LexicalEntry {
  final CoreData core;
  final List<Sense> senses;
  final GrammarData grammar;
  final LinguisticData linguistic;
  final DictionaryLayer dictionaryLayer;

  DictionaryLayer get lexiLens => dictionaryLayer;

  LexicalEntry({
    required this.core,
    required this.senses,
    required this.grammar,
    required this.linguistic,
    required this.dictionaryLayer,
  });

  factory LexicalEntry.fromMwJson(Map<String, dynamic> json) {
    String cleanText(String? input) {
      if (input == null) return '';
      return input.replaceAll(RegExp(r'\{.*?\}'), '').trim();
    }

    // 1. Core Data
    final hwi = json['hwi'] as Map<String, dynamic>?;
    final rawHw = hwi?['hw'] as String? ?? '';
    final headword = cleanText(rawHw).replaceAll('*', '');
    final homograph = json['hom'] is int ? json['hom'] as int : 0;
    final partOfSpeech = json['fl'] ?? '';
    final syllables = rawHw.split('*').map((s) => cleanText(s)).where((s) => s.isNotEmpty).toList();

    String phonetic = '';
    String audioUrl = '';
    if (hwi != null && hwi['prs'] != null && (hwi['prs'] as List).isNotEmpty) {
      final prs = hwi['prs'][0];
      phonetic = '/${cleanText(prs['mw'])}/';
      if (prs['sound'] != null && prs['sound']['audio'] != null) {
        final audioFile = prs['sound']['audio'] as String;
        String dir = '';
        if (audioFile.startsWith('bix')) {
          dir = 'bix';
        } else if (audioFile.startsWith('gg')) {
          dir = 'gg';
        } else if (RegExp(r'^[^a-zA-Z]').hasMatch(audioFile)) {
          dir = 'number';
        } else {
          dir = audioFile[0];
        }
        audioUrl = 'https://media.merriam-webster.com/audio/prons/en/us/mp3/$dir/$audioFile.mp3';
      }
    }

    final core = CoreData(
      headword: headword,
      homograph: homograph,
      partOfSpeech: partOfSpeech,
      phonetic: phonetic,
      audioUrl: audioUrl,
      syllables: syllables,
    );

    // 2. Senses (Nested Definitions & Examples)
    List<Sense> senses = [];
    List<String> globalUsageNotes = [];
    String verbDivision = '';

    if (json['def'] != null) {
      for (var defObj in (json['def'] as List)) {
        if (defObj is Map && defObj.containsKey('vd')) {
          verbDivision = cleanText(defObj['vd']);
        }
        if (defObj is Map && defObj.containsKey('sseq')) {
          for (var sseq in (defObj['sseq'] as List)) {
            for (var senseTuple in sseq) {
              if (senseTuple is List && senseTuple.length > 1) {
                // Senses can be direct ["sense", {...}] or wrapped in "pseq" or "bs"
                void processSenseMap(Map<String, dynamic> senseMap) {
                  final sn = cleanText(senseMap['sn']);
                  String defText = '';
                  List<String> examples = [];
                  List<String> labels = [];

                  if (senseMap['dt'] != null) {
                    for (var dtItem in (senseMap['dt'] as List)) {
                      if (dtItem is List && dtItem.length > 1) {
                        if (dtItem[0] == 'text') {
                          defText += cleanText(dtItem[1].toString()) + ' ';
                        } else if (dtItem[0] == 'vis') {
                          for (var visObj in (dtItem[1] as List)) {
                            if (visObj is Map && visObj.containsKey('t')) {
                              examples.add(cleanText(visObj['t']));
                            }
                          }
                        } else if (dtItem[0] == 'uns') {
                          // Usage notes inside uns
                          for (var unsTuple in (dtItem[1] as List)) {
                            if (unsTuple is List && unsTuple.length > 1 && unsTuple[0] == 'text') {
                              globalUsageNotes.add(cleanText(unsTuple[1].toString()));
                            }
                          }
                        }
                      }
                    }
                  }

                  if (senseMap['sls'] != null) {
                    labels = (senseMap['sls'] as List).map((l) => cleanText(l.toString())).toList();
                  }

                  if (defText.trim().isNotEmpty) {
                    senses.add(Sense(
                      senseNumber: sn,
                      definition: defText.trim(),
                      examples: examples,
                      labels: labels,
                    ));
                  }
                }

                final firstItem = senseTuple[0];
                if (firstItem == 'sense' && senseTuple[1] is Map) {
                  processSenseMap(senseTuple[1] as Map<String, dynamic>);
                } else if ((firstItem == 'pseq' || firstItem == 'bs') && senseTuple[1] is List) {
                  for (var subItem in (senseTuple[1] as List)) {
                    if (subItem is List && subItem.length > 1 && subItem[0] == 'sense' && subItem[1] is Map) {
                      processSenseMap(subItem[1] as Map<String, dynamic>);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    // 3. Grammar Data
    List<String> inflections = [];
    if (json['ins'] != null) {
      for (var inObj in (json['ins'] as List)) {
        if (inObj is Map && inObj.containsKey('if')) {
          inflections.add(cleanText(inObj['if']));
        }
      }
    }

    List<String> relatedForms = [];
    if (json['uros'] != null) {
      for (var uro in (json['uros'] as List)) {
        if (uro is Map && uro.containsKey('ure')) {
          final form = cleanText(uro['ure']);
          final pos = uro['fl'] != null ? ' (${cleanText(uro['fl'])})' : '';
          relatedForms.add('$form$pos');
        }
      }
    }

    final grammar = GrammarData(
      verbDivision: verbDivision,
      usageNotes: globalUsageNotes,
      inflections: inflections,
      relatedForms: relatedForms,
    );

    // 4. Linguistic Data
    String etymology = '';
    if (json['et'] != null) {
      for (var etItem in (json['et'] as List)) {
        if (etItem is List && etItem.length > 1 && etItem[0] == 'text') {
          etymology += cleanText(etItem[1].toString()) + ' ';
        }
      }
    }

    String firstKnownUse = '';
    if (json['date'] != null) {
      firstKnownUse = cleanText(json['date'].toString());
    }

    final linguistic = LinguisticData(
      etymology: etymology.trim(),
      firstKnownUse: firstKnownUse,
    );

    // 5. LexiLens AI Layer (Defaults & Extraction)
    String simpleMeaning = senses.isNotEmpty ? senses.first.definition : 'A lexical entry for $headword';
    // Remove complex leading notation for simple meaning
    if (simpleMeaning.contains(':')) {
      final parts = simpleMeaning.split(':');
      simpleMeaning = parts.where((p) => p.trim().isNotEmpty).first.trim();
    }

    String contextualMeaning = senses.isNotEmpty && senses.first.examples.isNotEmpty
        ? senses.first.examples.first
        : 'Used in everyday context and reading.';

    final dictionaryLayer = DictionaryLayer(
      simpleMeaning: simpleMeaning,
      contextualMeaning: contextualMeaning,
      synonyms: [],
      antonyms: [],
    );

    return LexicalEntry(
      core: core,
      senses: senses,
      grammar: grammar,
      linguistic: linguistic,
      dictionaryLayer: dictionaryLayer,
    );
  }
}
