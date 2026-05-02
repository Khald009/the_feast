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

    // Build mistake counts map
    final mistakeCounts = <String, int>{};
    for (final mistake in mistakes.where((m) => m.lectureId == lectureId)) {
      final sentence = mistake.description;
      mistakeCounts[sentence] = (mistakeCounts[sentence] ?? 0) + 1;
    }

    return sortSentencesByDifficulty(
      wrongIndexes.map((i) => sentences[i]).toList(),
      sentenceAccuracies ?? {},
      mistakeCounts,
    ).map((i) => wrongIndexes[i]).toList();
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

  /// Calculate difficulty score for a sentence based on length, complexity, and mistake history
  static double calculateDifficultyScore(
    String sentence,
    Map<String, double> sentenceAccuracies,
    Map<String, int> mistakeCounts,
  ) {
    final words = _tokenize(sentence);
    final wordCount = words.length;
    final avgAccuracy = sentenceAccuracies[sentence] ?? 1.0;
    final mistakeCount = mistakeCounts[sentence] ?? 0;

    // Base difficulty from length (longer sentences are harder)
    double difficulty = wordCount / 20.0; // Normalize around 20 words

    // Adjust for accuracy (lower accuracy = higher difficulty)
    difficulty += (1.0 - avgAccuracy) * 2.0;

    // Adjust for mistake history (more mistakes = higher difficulty)
    difficulty += mistakeCount * 0.1;

    // Add complexity factors
    final complexWords = words.where((w) => w.length > 8).length;
    difficulty += complexWords * 0.05;

    return difficulty.clamp(0.1, 5.0); // Clamp between 0.1 and 5.0
  }

  /// Sort sentence indexes by difficulty for retry mode
  static List<int> sortSentencesByDifficulty(
    List<String> sentences,
    Map<String, double> sentenceAccuracies,
    Map<String, int> mistakeCounts,
  ) {
    final indexedDifficulties = sentences.asMap().entries.map((entry) {
      final index = entry.key;
      final sentence = entry.value;
      final difficulty =
          calculateDifficultyScore(sentence, sentenceAccuracies, mistakeCounts);
      return MapEntry(index, difficulty);
    }).toList();

    indexedDifficulties.sort((a, b) =>
        b.value.compareTo(a.value)); // Sort descending (hardest first)
    return indexedDifficulties.map((e) => e.key).toList();
  }

  /// Track wrong words frequency across sentences
  static Map<String, int> trackWrongWords(
    List<String> sourceSentences,
    List<String> userInputs,
  ) {
    final wrongWords = <String, int>{};

    for (var i = 0; i < sourceSentences.length && i < userInputs.length; i++) {
      final sourceWords = _tokenize(sourceSentences[i]);

      final comparison = compareSentence(sourceSentences[i], userInputs[i]);
      for (var j = 0; j < comparison.length; j++) {
        if (!comparison[j].correct) {
          final sourceWord =
              j < sourceWords.length ? _normalize(sourceWords[j]) : '';
          if (sourceWord.isNotEmpty) {
            wrongWords[sourceWord] = (wrongWords[sourceWord] ?? 0) + 1;
          }
        }
      }
    }

    return wrongWords;
  }
}
