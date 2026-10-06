class FuzzyMatch<T> {
  final T item;
  final String word;
  final double similarity;
  final int distance;

  FuzzyMatch({
    required this.item,
    required this.word,
    required this.similarity,
    required this.distance,
  });
}

class FuzzySearch {
  static List<FuzzyMatch<T>> rankMatches<T>({
    required String query,
    required List<T> candidates,
    required String Function(T) wordExtractor,
    double minSimilarity = 0.0,
    int? maxResults,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final List<FuzzyMatch<T>> matches = [];

    for (final candidate in candidates) {
      final candidateWord = wordExtractor(candidate);
      final cleanCandidate = candidateWord.trim().toLowerCase();
      if (cleanCandidate.isEmpty) continue;

      final dist = _levenshteinDistance(cleanQuery, cleanCandidate);
      final maxLen = cleanQuery.length > cleanCandidate.length
          ? cleanQuery.length
          : cleanCandidate.length;

      double sim = maxLen == 0 ? 1.0 : (1.0 - (dist / maxLen));

      // Slight boost if candidate starts with query
      if (cleanCandidate.startsWith(cleanQuery)) {
        sim = (sim + 0.15).clamp(0.0, 1.0);
      }

      if (sim >= minSimilarity) {
        matches.add(FuzzyMatch(
          item: candidate,
          word: candidateWord,
          similarity: sim,
          distance: dist,
        ));
      }
    }

    matches.sort((a, b) {
      final simComp = b.similarity.compareTo(a.similarity);
      if (simComp != 0) return simComp;
      return a.distance.compareTo(b.distance);
    });

    if (maxResults != null && matches.length > maxResults) {
      return matches.sublist(0, maxResults);
    }

    return matches;
  }

  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1.codeUnitAt(i) == s2.codeUnitAt(j)) ? 0 : 1;
        int min1 = v1[j] + 1;
        int min2 = v0[j + 1] + 1;
        int min3 = v0[j] + cost;
        int min = min1 < min2 ? min1 : min2;
        v1[j + 1] = min < min3 ? min : min3;
      }

      for (int j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }
}
