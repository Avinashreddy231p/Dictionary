String formatPartOfSpeech(String? rawPos) {
  if (rawPos == null || rawPos.trim().isEmpty) {
    return 'word';
  }

  final clean = rawPos.trim().toLowerCase();

  if (clean == 'n' || clean == 'n.' || clean == 'noun' || clean == 'nouns') {
    return 'noun';
  }
  if (clean == 'v.t.' || clean == 'vt' || clean == 'v. t.' || clean == 'transitive verb' || clean == 'v. t') {
    return 'verb (transitive)';
  }
  if (clean == 'v.i.' || clean == 'vi' || clean == 'v. i.' || clean == 'intransitive verb' || clean == 'v. i') {
    return 'verb (intransitive)';
  }
  if (clean == 'v' || clean == 'v.' || clean == 'verb' || clean == 'verbs') {
    return 'verb';
  }
  if (clean == 'adj' || clean == 'adj.' || clean == 'a.' || clean == 'a' || clean == 'adjective' || clean == 'adjectives') {
    return 'adjective';
  }
  if (clean == 'adv' || clean == 'adv.' || clean == 'adverb' || clean == 'adverbs') {
    return 'adverb';
  }
  if (clean == 'prep' || clean == 'prep.' || clean == 'preposition' || clean == 'prepositions') {
    return 'preposition';
  }
  if (clean == 'conj' || clean == 'conj.' || clean == 'conjunction' || clean == 'conjunctions') {
    return 'conjunction';
  }
  if (clean == 'interj' || clean == 'interj.' || clean == 'interjection' || clean == 'interjections') {
    return 'interjection';
  }
  if (clean == 'pron' || clean == 'pron.' || clean == 'pronoun' || clean == 'pronouns') {
    return 'pronoun';
  }

  // Fallback string replacements for compound strings
  return clean
      .replaceAll('v.t.', 'verb (transitive)')
      .replaceAll('v.i.', 'verb (intransitive)')
      .replaceAll('n.', 'noun')
      .replaceAll('v.', 'verb')
      .replaceAll('adj.', 'adjective')
      .replaceAll('adv.', 'adverb')
      .replaceAll('prep.', 'preposition')
      .replaceAll('conj.', 'conjunction')
      .replaceAll('interj.', 'interjection')
      .replaceAll('a.', 'adjective');
}
