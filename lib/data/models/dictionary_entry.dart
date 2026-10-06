class DictionaryEntry {
  // Core
  final String word;
  final String partOfSpeech;
  final String phonetic;
  final List<String> syllables;

  // Meaning
  final List<String> meanings;
  final List<String> examples;

  // Relationships
  final List<String> synonyms;
  final List<String> antonyms;

  // Grammar
  final List<String> inflections;
  final List<String> grammaticalInfo;

  // Usage
  final List<String> registers;
  final List<String> domains;

  // Linguistic
  final String etymology;

  DictionaryEntry({
    required this.word,
    required this.partOfSpeech,
    required this.phonetic,
    required this.syllables,
    required this.meanings,
    required this.examples,
    required this.synonyms,
    required this.antonyms,
    required this.inflections,
    required this.grammaticalInfo,
    required this.registers,
    required this.domains,
    required this.etymology,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    String cleanText(String? input) {
      if (input == null) return '';
      return input.replaceAll(RegExp(r'\{.*?\}'), '').trim();
    }

    // Core
    final hwi = json['hwi'] as Map<String, dynamic>?;
    final rawWord = hwi?['hw'] as String? ?? '';
    final word = cleanText(rawWord).replaceAll('*', '');
    final syllables = rawWord.split('*').map((s) => cleanText(s)).where((s) => s.isNotEmpty).toList();
    final fl = json['fl'] ?? 'unknown';

    String phonetic = '';
    if (hwi != null && hwi['prs'] != null && (hwi['prs'] as List).isNotEmpty) {
      phonetic = '/${cleanText(hwi['prs'][0]['mw'])}/';
    }

    // Meaning
    List<String> meanings = [];
    if (json['shortdef'] != null) {
      meanings = (json['shortdef'] as List).map((e) => cleanText(e.toString())).toList();
    }

    // Deep search for examples ("vis" objects), labels ("lbs", "sls"), and grammar ("vd")
    List<String> examples = [];
    List<String> registers = [];
    List<String> domains = [];
    List<String> grammaticalInfo = [];

    if (json['lbs'] != null) {
       registers.addAll((json['lbs'] as List).map((e) => cleanText(e.toString())));
    }
    if (json['sls'] != null) {
       domains.addAll((json['sls'] as List).map((e) => cleanText(e.toString())));
    }

    void extractNestedData(dynamic node) {
      if (node is Map) {
        if (node.containsKey('vis')) {
          for (var v in (node['vis'] as List)) {
            if (v['t'] != null) examples.add(cleanText(v['t']));
          }
        }
        if (node.containsKey('vd')) {
          grammaticalInfo.add(cleanText(node['vd'])); // e.g., transitive verb
        }
        if (node.containsKey('sls')) { // Subject/status labels deep in senses
          domains.addAll((node['sls'] as List).map((e) => cleanText(e.toString())));
        }
        if (node.containsKey('lbs')) { // General labels deep in senses
          registers.addAll((node['lbs'] as List).map((e) => cleanText(e.toString())));
        }
        for (var value in node.values) {
          extractNestedData(value);
        }
      } else if (node is List) {
        for (var item in node) {
          extractNestedData(item);
        }
      }
    }
    extractNestedData(json['def'] ?? []);

    // Etymology
    String etymology = '';
    if (json['et'] != null && (json['et'] as List).isNotEmpty) {
      final etList = json['et'] as List;
      if (etList[0] is List && etList[0].length > 1) {
        etymology = cleanText(etList[0][1]);
      }
    }

    // Inflections
    List<String> inflections = [];
    if (json['ins'] != null) {
      for (var ins in (json['ins'] as List)) {
        if (ins['if'] != null) {
          inflections.add(cleanText(ins['if']).replaceAll('*', ''));
        }
      }
    }

    // Deduplicate lists
    inflections = inflections.toSet().where((i) => i != word).toList();
    examples = examples.toSet().toList();
    registers = registers.toSet().toList();
    domains = domains.toSet().toList();
    grammaticalInfo = grammaticalInfo.toSet().toList();

    return DictionaryEntry(
      word: word,
      partOfSpeech: fl,
      phonetic: phonetic,
      syllables: syllables,
      meanings: meanings,
      examples: examples,
      synonyms: [], // Placeholder for Thesaurus API integration
      antonyms: [], // Placeholder for Thesaurus API integration
      inflections: inflections,
      grammaticalInfo: grammaticalInfo,
      registers: registers,
      domains: domains,
      etymology: etymology,
    );
  }
}