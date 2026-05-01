import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lecture.dart';
import '../models/content.dart';
import '../models/mistake.dart';
import '../providers/mistake_provider.dart';
import '../providers/user_progress_provider.dart';

class StudyScreen extends ConsumerStatefulWidget {
  final Lecture lecture;
  final List<Content> contents;

  const StudyScreen({super.key, required this.lecture, required this.contents});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  late final List<String> sentences;
  int currentIndex = 0;
  bool isMemorizationMode = false;
  bool hasSubmitted = false;
  bool retryOnly = false;
  final TextEditingController memorizationController = TextEditingController();
  List<WordComparison> wordComparisons = [];
  final Set<int> importantIndexes = {};
  final Set<int> memorizedIndexes = {};

  @override
  void initState() {
    super.initState();
    sentences = _buildSentences(widget.contents);
  }

  @override
  void dispose() {
    memorizationController.dispose();
    super.dispose();
  }

  List<String> _buildSentences(List<Content> contents) {
    final rawText = contents
        .where((content) => content.type == ContentType.text)
        .map((content) => content.data.trim())
        .where((text) => text.isNotEmpty)
        .join(' ');

    final split = rawText.split(RegExp(r'(?<=[.!?])\s+'));
    return split.map((sentence) => sentence.trim()).where((sentence) => sentence.isNotEmpty).toList();
  }

  List<String> _tokenize(String sentence) {
    return sentence
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  String _normalize(String word) {
    final cleaned = word.toLowerCase().replaceAll(RegExp(r"[^a-z0-9']+"), '');
    return cleaned;
  }

  bool _wordsMatch(String source, String input) {
    return _normalize(source) == _normalize(input);
  }

  List<WordComparison> _compareSentence(String sentence, String userInput) {
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

      if (inputIndex + 1 < inputWords.length && _wordsMatch(sourceWord, inputWords[inputIndex + 1])) {
        inputIndex += 1;
        continue;
      }

      if (sourceIndex + 1 < sourceWords.length && _wordsMatch(sourceWords[sourceIndex + 1], inputWord)) {
        results.add(WordComparison(sourceWord, false, inputWord));
        sourceIndex += 1;
        continue;
      }

      if (sourceIndex + 2 < sourceWords.length && _wordsMatch(sourceWords[sourceIndex + 2], inputWord)) {
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

  double _calculateAccuracy(List<WordComparison> comparisons) {
    if (comparisons.isEmpty) return 0.0;
    final correct = comparisons.where((item) => item.correct).length;
    return correct / comparisons.length;
  }

  String _getFeedbackMessage(double accuracy) {
    if (accuracy >= 0.9) return 'Excellent! 🎉';
    if (accuracy >= 0.7) return 'Good! Keep practicing';
    return 'Needs Improvement. Try again';
  }

  Color _getFeedbackColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.7) return Colors.blue;
    return Colors.orange;
  }

  void _startMemorization() {
    setState(() {
      isMemorizationMode = true;
      hasSubmitted = false;
      wordComparisons = [];
      memorizationController.clear();
    });
  }

  void _cancelMemorization() {
    setState(() {
      isMemorizationMode = false;
      hasSubmitted = false;
      wordComparisons = [];
      memorizationController.clear();
    });
  }

  Future<void> _submitMemorization() async {
    final currentSentence = _currentSentence;
    final input = memorizationController.text.trim();
    final comparisons = _compareSentence(currentSentence, input);
    final accuracy = _calculateAccuracy(comparisons);
    final wrongWords = comparisons.where((item) => !item.correct).map((item) => item.sourceWord).toSet().toList();

    // Track accuracy in UserProgress
    await ref.read(userProgressProvider.notifier).trackAccuracy(
          widget.lecture.id,
          currentSentence,
          accuracy,
        );

    setState(() {
      wordComparisons = comparisons;
      hasSubmitted = true;
    });

    if (wrongWords.isNotEmpty) {
      final existing = ref.read(mistakeProvider).any(
            (m) => m.lectureId == widget.lecture.id && m.description == currentSentence,
          );
      if (!existing) {
        final mistake = Mistake(
          id: DateTime.now().toString(),
          lectureId: widget.lecture.id,
          description: currentSentence,
          correction: wrongWords.join(', '),
          date: DateTime.now(),
        );
        await ref.read(mistakeProvider.notifier).addMistake(mistake);
      }
    }
  }

  void _toggleImportant() {
    final sentenceIndex = _currentSentenceIndex;
    setState(() {
      if (importantIndexes.contains(sentenceIndex)) {
        importantIndexes.remove(sentenceIndex);
      } else {
        importantIndexes.add(sentenceIndex);
      }
    });
  }

  void _toggleMemorized() {
    final sentenceIndex = _currentSentenceIndex;
    setState(() {
      if (memorizedIndexes.contains(sentenceIndex)) {
        memorizedIndexes.remove(sentenceIndex);
      } else {
        memorizedIndexes.add(sentenceIndex);
      }
    });
  }

  void _nextSentence(int sentenceCount) {
    if (currentIndex < sentenceCount - 1) {
      setState(() {
        currentIndex += 1;
        hasSubmitted = false;
        wordComparisons = [];
        memorizationController.clear();
      });
    }
  }

  void _previousSentence() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex -= 1;
        hasSubmitted = false;
        wordComparisons = [];
        memorizationController.clear();
      });
    }
  }

  void _toggleRetryMode() {
    setState(() {
      retryOnly = !retryOnly;
      currentIndex = 0;
      hasSubmitted = false;
      wordComparisons = [];
      memorizationController.clear();
    });
  }

  Set<int> _savedWrongSentenceIndexes(List<Mistake> mistakes) {
    final wrongIndexes = <int>{};
    for (var entry in sentences.asMap().entries) {
      final sentence = entry.value;
      if (mistakes.any((m) => m.lectureId == widget.lecture.id && m.description == sentence)) {
        wrongIndexes.add(entry.key);
      }
    }
    return wrongIndexes;
  }

  List<int> _getSortedActiveSentenceIndexes(List<int> baseIndexes, Map<String, dynamic>? sentenceAccuracies) {
    if (!retryOnly || sentenceAccuracies == null) return baseIndexes;

    return baseIndexes
      ..sort((a, b) {
        final accuracyA = (sentenceAccuracies[sentences[a]] as num?)?.toDouble() ?? 1.0;
        final accuracyB = (sentenceAccuracies[sentences[b]] as num?)?.toDouble() ?? 1.0;
        return accuracyA.compareTo(accuracyB); // Ascending: worst first
      });
  }

  List<int> get _activeSentenceIndexes {
    final allIndexes = List<int>.generate(sentences.length, (index) => index);
    if (!retryOnly) return allIndexes;

    final mistakes = ref.watch(mistakeProvider);
    final wrongIndexes = _savedWrongSentenceIndexes(mistakes).toList()..sort();

    final progress = ref.watch(userProgressProvider);
    final lectureProgress = progress.firstWhere(
      (p) => p.lectureId == widget.lecture.id,
      orElse: () => null as dynamic,
    );

    final sentenceAccuracies = (lectureProgress as dynamic)?.sentenceAccuracies as Map<String, dynamic>?;
    return _getSortedActiveSentenceIndexes(wrongIndexes, sentenceAccuracies);
  }

  int get _currentSentenceIndex {
    final indexes = _activeSentenceIndexes;
    if (indexes.isEmpty) return 0;
    return indexes[currentIndex.clamp(0, indexes.length - 1)];
  }

  String get _currentSentence => sentences[_currentSentenceIndex];

  Widget _buildComparisonResult() {
    if (!hasSubmitted) return const SizedBox.shrink();
    if (wordComparisons.isEmpty) {
      return const SizedBox.shrink();
    }

    final accuracy = _calculateAccuracy(wordComparisons);
    final correctCount = wordComparisons.where((item) => item.correct).length;
    final wrongCount = wordComparisons.where((item) => !item.correct).length;
    final accuracyPercentage = (accuracy * 100).toStringAsFixed(0);
    final feedback = _getFeedbackMessage(accuracy);
    final feedbackColor = _getFeedbackColor(accuracy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: feedbackColor.withAlpha(25),
            border: Border.all(color: feedbackColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Accuracy: $accuracyPercentage%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: feedbackColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$correctCount correct / $wrongCount wrong words',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: feedbackColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                feedback,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: feedbackColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Word comparison:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: wordComparisons.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: item.correct ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.sourceWord,
                  style: TextStyle(
                    color: item.correct ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIndexes = _activeSentenceIndexes;
    final hasAllSentences = sentences.isNotEmpty;
    final hasActiveSentences = activeIndexes.isNotEmpty;
    final totalSentences = activeIndexes.length;
    final currentSentenceNumber = hasActiveSentences ? currentIndex + 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Study: ${widget.lecture.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasAllSentences
            ? hasActiveSentences
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              retryOnly
                                  ? 'Retry wrong sentence $currentSentenceNumber of $totalSentences'
                                  : 'Sentence $currentSentenceNumber of $totalSentences',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: _toggleRetryMode,
                            child: Text(retryOnly ? 'All Sentences' : 'Retry Wrong'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isMemorizationMode)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _currentSentence,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Type the sentence from memory:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: TextField(
                                  controller: memorizationController,
                                  maxLines: null,
                                  expands: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Remember and type the sentence here',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _submitMemorization,
                                      child: const Text('Submit'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _cancelMemorization,
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      if (!isMemorizationMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: _startMemorization,
                            child: const Text('Start Memorization'),
                          ),
                        ),
                      if (isMemorizationMode) const SizedBox(height: 16),
                      _buildComparisonResult(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleImportant,
                              icon: Icon(
                                importantIndexes.contains(_currentSentenceIndex) ? Icons.star : Icons.star_border,
                              ),
                              label: Text(importantIndexes.contains(_currentSentenceIndex) ? 'Unmark Important' : 'Mark Important'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleMemorized,
                              icon: Icon(
                                memorizedIndexes.contains(_currentSentenceIndex) ? Icons.check_circle : Icons.check_circle_outline,
                              ),
                              label: Text(memorizedIndexes.contains(_currentSentenceIndex) ? 'Unmark Memorized' : 'Mark Memorized'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousSentence,
                              child: const Text('Previous'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _nextSentence(totalSentences),
                              child: const Text('Next'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Text(retryOnly ? 'No wrong sentences saved yet.' : 'No text content available for study mode.'),
                  )
            : const Center(
                child: Text('No text content available for study mode.'),
              ),
      ),
    );
  }
}

class WordComparison {
  final String sourceWord;
  final bool correct;
  final String? typedWord;

  WordComparison(this.sourceWord, this.correct, this.typedWord);
}
