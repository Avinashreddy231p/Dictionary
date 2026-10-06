class CoreData {
  final String headword;
  final int homograph;
  final String partOfSpeech;
  final String phonetic;
  final String audioUrl;
  final List<String> syllables;

  CoreData({
    required this.headword,
    required this.homograph,
    required this.partOfSpeech,
    required this.phonetic,
    required this.audioUrl,
    required this.syllables,
  });
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

class LexiLensLayer {
  final String simpleMeaning;
  final String contextualMeaning;
  final List<String> synonyms;
  final List<String> antonyms;

  LexiLensLayer({
    required this.simpleMeaning,
    required this.contextualMeaning,
    required this.synonyms,
    required this.antonyms,
  });

  LexiLensLayer copyWith({
    String? simpleMeaning,
    String? contextualMeaning,
    List<String>? synonyms,
    List<String>? antonyms,
  }) {
    return LexiLensLayer(
      simpleMeaning: simpleMeaning ?? this.simpleMeaning,
      contextualMeaning: contextualMeaning ?? this.contextualMeaning,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
    );
  }
}

class LexicalEntry {
  final CoreData core;
  final List<Sense> senses;
  final GrammarData grammar;
  final LinguisticData linguistic;
  final LexiLensLayer lexiLens;

  LexicalEntry({
    required this.core,
    required this.senses,
    required this.grammar,
    required this.linguistic,
    required this.lexiLens,
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
                  String definition = '';
                  List<String> examples = [];
                  List<String> labels = [];

                  if (senseMap['sls'] != null) {
                    labels.addAll((senseMap['sls'] as List).map((e) => cleanText(e.toString())));
                  }

                  if (senseMap['dt'] != null) {
                    for (var dtItem in (senseMap['dt'] as List)) {
                      if (dtItem is List && dtItem.length > 1) {
                        if (dtItem[0] == 'text') {
                          definition += cleanText(dtItem[1].toString()) + ' ';
                        } else if (dtItem[0] == 'vis') {
                          for (var v in (dtItem[1] as List)) {
                            if (v is Map && v.containsKey('t')) {
                              examples.add(cleanText(v['t'].toString()));
                            }
                          }
                        } else if (dtItem[0] == 'uns') {
                          for (var uGroup in (dtItem[1] as List)) {
                            for (var u in uGroup) {
                              if (u is List && u.length > 1 && u[0] == 'text') {
                                globalUsageNotes.add(cleanText(u[1].toString()));
                              }
                            }
                          }
                        }
                      }
                    }
                  }

                  if (definition.trim().isNotEmpty) {
                    senses.add(Sense(
                      senseNumber: sn,
                      definition: definition.trim(),
                      examples: examples,
                      labels: labels,
                    ));
                  }
                }

                if (senseTuple[0] == 'sense') {
                  processSenseMap(senseTuple[1] as Map<String, dynamic>);
                } else if (senseTuple[0] == 'pseq' || senseTuple[0] == 'bs') {
                  for (var subItem in (senseTuple[1] as List)) {
                    if (subItem is List && subItem.length > 1 && subItem[0] == 'sense') {
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

    // Fallback for senses if def parsing was empty
    if (senses.isEmpty && json['shortdef'] != null) {
      int count = 1;
      for (var sd in (json['shortdef'] as List)) {
        senses.add(Sense(
          senseNumber: '$count',
          definition: cleanText(sd.toString()),
          examples: [],
          labels: [],
        ));
        count++;
      }
    }

    // 3. Grammar Data
    List<String> inflections = [];
    if (json['ins'] != null) {
      for (var ins in (json['ins'] as List)) {
        if (ins['if'] != null) {
          inflections.add(cleanText(ins['if']).replaceAll('*', ''));
        }
      }
    }

    List<String> relatedForms = [];
    if (json['uros'] != null) {
      for (var uro in (json['uros'] as List)) {
        if (uro['ure'] != null) {
          relatedForms.add(cleanText(uro['ure']).replaceAll('*', ''));
        }
      }
    }

    final grammar = GrammarData(
      verbDivision: verbDivision,
      usageNotes: globalUsageNotes.toSet().toList(),
      inflections: inflections.toSet().where((i) => i != headword).toList(),
      relatedForms: relatedForms.toSet().toList(),
    );

    // 4. Linguistic Data
    String etymology = '';
    if (json['et'] != null && (json['et'] as List).isNotEmpty) {
      final etList = json['et'] as List;
      if (etList[0] is List && etList[0].length > 1) {
        etymology = cleanText(etList[0][1]);
      }
    }

    final firstKnownUse = cleanText(json['date']?.toString());

    final linguistic = LinguisticData(
      etymology: etymology,
      firstKnownUse: firstKnownUse,
    );

    // 5. Initial LexiLens Layer
    final firstDef = senses.isNotEmpty ? senses.first.definition : 'Vocabulary term';
    String simpleMeaning = firstDef.split(';').first;
    if (simpleMeaning.startsWith(':')) {
      simpleMeaning = simpleMeaning.substring(1).trim();
    }

    final lexiLens = LexiLensLayer(
      simpleMeaning: simpleMeaning.isNotEmpty ? simpleMeaning : firstDef,
      contextualMeaning: '',
      synonyms: [],
      antonyms: [],
    );

    return LexicalEntry(
      core: core,
      senses: senses,
      grammar: grammar,
      linguistic: linguistic,
      lexiLens: lexiLens,
    );
  }
}