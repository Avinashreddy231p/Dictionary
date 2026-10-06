class DictionaryEntry {
  final String word;
  final String partOfSpeech;
  final String phonetic;
  final String meaning;
  final String example;

  DictionaryEntry({
    required this.word,
    required this.partOfSpeech,
    required this.phonetic,
    required this.meaning,
    required this.example,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    // Extract word
    final hwi = json['hwi'] as Map<String, dynamic>?;
    final word = hwi?['hw'] ?? '';

    // Extract part of speech
    final fl = json['fl'] ?? '';

    // Extract phonetic
    String phonetic = '';
    if (hwi != null && hwi['prs'] != null && (hwi['prs'] as List).isNotEmpty) {
      phonetic = '/${hwi['prs'][0]['mw']}/';
    }

    // Extract meaning from shortdef
    String meaning = '';
    if (json['shortdef'] != null && (json['shortdef'] as List).isNotEmpty) {
      meaning = (json['shortdef'] as List).first.toString();
    }

    // Extract example (this can be complex in Merriam-Webster, trying to find 'vis')
    String example = '';
    try {
      final defs = json['def'] as List?;
      if (defs != null && defs.isNotEmpty) {
        final sseq = defs[0]['sseq'] as List?;
        if (sseq != null && sseq.isNotEmpty) {
          final senseGroup = sseq[0][0];
          if (senseGroup is List && senseGroup.length > 1) {
            final sense = senseGroup[1] as Map<String, dynamic>?;
            if (sense != null && sense['dt'] != null) {
              final dt = sense['dt'] as List;
              for (var item in dt) {
                if (item is List && item.length > 1 && item[0] == 'vis') {
                  final vis = item[1] as List;
                  if (vis.isNotEmpty) {
                    example = vis[0]['t']?.replaceAll(RegExp(r'\{.*?\}'), '') ?? '';
                    break;
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // Ignore if example parsing fails
    }

    return DictionaryEntry(
      word: word.replaceAll('*', ''), // MW sometimes adds * for syllables
      partOfSpeech: fl,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
    );
  }
}