import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lecture.dart';
import '../models/content.dart';
import '../models/mistake.dart';
import '../providers/mistake_provider.dart';
import '../providers/user_progress_provider.dart';
import '../providers/derived_providers.dart';
import '../core/study_engine.dart';
import '../widgets/comparison_result.dart';
import '../widgets/sentence_view.dart';
import '../widgets/memorization_input.dart';

class StudyScreen extends ConsumerStatefulWidget {
  final Lecture lecture;
  final List<Content> contents;

  const StudyScreen({super.key, required this.lecture, required this.contents});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  int currentIndex = 0;
  bool isMemorizationMode = false;
  bool hasSubmitted = false;
  bool retryOnly = false;
  final TextEditingController memorizationController = TextEditingController();
  List<WordComparison> wordComparisons = [];
  final Set<int> importantIndexes = {};
  final Set<int> memorizedIndexes = {};

  List<String> get sentences =>
      ref.watch(studySentencesProvider(widget.lecture.id));

  @override
  void dispose() {
    memorizationController.dispose();
    super.dispose();
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
    final comparisons = StudyEngine.compareSentence(currentSentence, input);
    final accuracy = StudyEngine.calculateAccuracy(comparisons);
    final wrongWords = comparisons
        .where((item) => !item.correct)
        .map((item) => item.sourceWord)
        .toSet()
        .toList();

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
            (m) =>
                m.lectureId == widget.lecture.id &&
                m.description == currentSentence,
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

  List<int> get _activeSentenceIndexes => StudyEngine.activeSentenceIndexes(
        sentences: sentences,
        retryOnly: retryOnly,
        mistakes: ref.watch(mistakeProvider),
        progressItems: ref.watch(userProgressProvider),
        lectureId: widget.lecture.id,
      );

  int get _currentSentenceIndex =>
      StudyEngine.clampSentenceIndex(currentIndex, _activeSentenceIndexes);

  String get _currentSentence => sentences[_currentSentenceIndex];

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
                            child: Text(
                                retryOnly ? 'All Sentences' : 'Retry Wrong'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isMemorizationMode)
                        Expanded(
                          child: SentenceView(sentence: _currentSentence),
                        )
                      else
                        Expanded(
                          child: MemorizationInput(
                            controller: memorizationController,
                            onSubmit: _submitMemorization,
                            onCancel: _cancelMemorization,
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
                      if (hasSubmitted && wordComparisons.isNotEmpty)
                        ComparisonResult(
                          comparisons: wordComparisons,
                          accuracy:
                              StudyEngine.calculateAccuracy(wordComparisons),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleImportant,
                              icon: Icon(
                                importantIndexes.contains(_currentSentenceIndex)
                                    ? Icons.star
                                    : Icons.star_border,
                              ),
                              label: Text(importantIndexes
                                      .contains(_currentSentenceIndex)
                                  ? 'Unmark Important'
                                  : 'Mark Important'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _toggleMemorized,
                              icon: Icon(
                                memorizedIndexes.contains(_currentSentenceIndex)
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                              ),
                              label: Text(memorizedIndexes
                                      .contains(_currentSentenceIndex)
                                  ? 'Unmark Memorized'
                                  : 'Mark Memorized'),
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
                    child: Text(retryOnly
                        ? 'No wrong sentences saved yet.'
                        : 'No text content available for study mode.'),
                  )
            : const Center(
                child: Text('No text content available for study mode.'),
              ),
      ),
    );
  }
}
