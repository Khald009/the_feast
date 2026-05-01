import '../models/mistake.dart';
import '../models/user_progress.dart';

class WordComparison {
  final String sourceWord;
  final bool correct;
  final String? typedWord;

  WordComparison(this.sourceWord, this.correct, this.typedWord);
}

class StudyEngine {
  static List<WordComparison> compareSentence(
      String sentence, String userInput) {
    final sourceWords = _tokenize(sentence);
    final inputWords = _tokenize(userInput);
    final results = <WordComparison>[];

    var sourceIndex = 0;
    var inputIndex = 0;

    while (sourceIndex < sourceWords.length && inputIndex < inputWords.length) {
      final sourceWord = sourceWords[sourceIndex];
      final inputWord = inputWords[inputIndex];

      if (_wordsMatch(sourceWord, inputWord)) {
        results.add(WordComparison(sourceWord, true, inputWord));
        sourceIndex += 1;
        inputIndex += 1;
        continue;
      }

      if (inputIndex + 1 < inputWords.length &&
          _wordsMatch(sourceWord, inputWords[inputIndex + 1])) {
        inputIndex += 1;
        continue;
      }

      if (sourceIndex + 1 < sourceWords.length &&
          _wordsMatch(sourceWords[sourceIndex + 1], inputWord)) {
        results.add(WordComparison(sourceWord, false, inputWord));
        sourceIndex += 1;
        continue;
      }

      if (sourceIndex + 2 < sourceWords.length &&
          _wordsMatch(sourceWords[sourceIndex + 2], inputWord)) {
        results.add(WordComparison(sourceWord, false, inputWord));
        results.add(WordComparison(sourceWords[sourceIndex + 1], false, null));
        sourceIndex += 2;
        continue;
      }

      results.add(WordComparison(sourceWord, false, inputWord));
      sourceIndex += 1;
      inputIndex += 1;
    }

    while (sourceIndex < sourceWords.length) {
      results.add(WordComparison(sourceWords[sourceIndex], false, null));
      sourceIndex += 1;
    }

    return results;
  }

  static double calculateAccuracy(List<WordComparison> comparisons) {
    if (comparisons.isEmpty) return 0.0;
    final correct = comparisons.where((item) => item.correct).length;
    return correct / comparisons.length;
  }

  static Set<int> wrongSentenceIndexes(
    List<String> sentences,
    List<Mistake> mistakes,
    String lectureId,
  ) {
    final wrongIndexes = <int>{};
    for (var entry in sentences.asMap().entries) {
      final sentence = entry.value;
      if (mistakes
          .any((m) => m.lectureId == lectureId && m.description == sentence)) {
        wrongIndexes.add(entry.key);
      }
    }
    return wrongIndexes;
  }

  static List<int> getSortedActiveSentenceIndexes(
    List<int> baseIndexes,
    List<String> sentences,
    Map<String, double>? sentenceAccuracies,
  ) {
    if (sentenceAccuracies == null) return List<int>.from(baseIndexes);

    final sortedIndexes = List<int>.from(baseIndexes);
    sortedIndexes.sort((a, b) {
      final sentenceA = a < sentences.length ? sentences[a] : '';
      final sentenceB = b < sentences.length ? sentences[b] : '';
      final accuracyA = sentenceAccuracies[sentenceA] ?? 1.0;
      final accuracyB = sentenceAccuracies[sentenceB] ?? 1.0;
      return accuracyA.compareTo(accuracyB);
    });
    return sortedIndexes;
  }

  static Map<String, double>? _normalizeSentenceAccuracies(
    Map<String, dynamic>? rawAccuracies,
  ) {
    if (rawAccuracies == null) return null;
    final normalized = <String, double>{};
    rawAccuracies.forEach((key, value) {
      if (value is num) {
        normalized[key] = value.toDouble();
      } else if (value is double) {
        normalized[key] = value;
      } else if (value is int) {
        normalized[key] = value.toDouble();
      }
    });
    return normalized.isEmpty ? null : normalized;
  }

  static List<int> activeSentenceIndexes({
    required List<String> sentences,
    required bool retryOnly,
    required List<Mistake> mistakes,
    required List<UserProgress> progressItems,
    required String lectureId,
  }) {
    final allIndexes = List<int>.generate(sentences.length, (index) => index);
    if (!retryOnly) return allIndexes;

    final wrongIndexes =
        wrongSentenceIndexes(sentences, mistakes, lectureId).toList();

    final matchingProgress =
        progressItems.where((p) => p.lectureId == lectureId).toList();
    final lectureProgress =
        matchingProgress.isEmpty ? null : matchingProgress.first;
    final sentenceAccuracies =
        _normalizeSentenceAccuracies(lectureProgress?.sentenceAccuracies);

    return getSortedActiveSentenceIndexes(
        wrongIndexes, sentences, sentenceAccuracies);
  }

  static int clampSentenceIndex(int currentIndex, List<int> activeIndexes) {
    if (activeIndexes.isEmpty) return 0;
    return activeIndexes[currentIndex.clamp(0, activeIndexes.length - 1)];
  }

  static List<String> _tokenize(String sentence) {
    return sentence
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static String _normalize(String word) {
    return word.toLowerCase().replaceAll(RegExp(r"[^a-z0-9']+"), '');
  }

  static bool _wordsMatch(String source, String input) {
    return _normalize(source) == _normalize(input);
  }
}
