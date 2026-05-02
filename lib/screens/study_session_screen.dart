import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lecture.dart';
import '../providers/memorization_provider.dart';
import '../widgets/typing_validation_widget.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  final Lecture lecture;
  final List<String> sentences;

  const StudySessionScreen({
    super.key,
    required this.lecture,
    required this.sentences,
  });

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(memorizationProvider.notifier).initializeSession(
        lecture: widget.lecture,
        sentences: widget.sentences,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final memorizationState = ref.watch(memorizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => _toggleTranslation(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _retrainErrors(),
          ),
        ],
      ),
      body: memorizationState.when(
        data: (state) => _buildSessionContent(state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSessionContent(MemorizationState state) {
    if (state.sentences.isEmpty) {
      return const Center(child: Text('No sentences to study'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProgressIndicator(state),
          const SizedBox(height: 24),
          _buildCurrentSentenceDisplay(state),
          const SizedBox(height: 24),
          if (state.isPlaying) _buildAudioPhase(state) else _buildTypingPhase(state),
          const SizedBox(height: 24),
          _buildControls(state),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(MemorizationState state) {
    final progress = state.sentences.isEmpty
        ? 0.0
        : (state.currentSentenceIndex + 1) / state.sentences.length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sentence ${state.currentSentenceIndex + 1} of ${state.sentences.length}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCurrentSentenceDisplay(MemorizationState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Sentence:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildHighlightedSentence(state),
            if (state.translationEnabled && state.translatedSentence.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Translation: ${state.translatedSentence}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedSentence(MemorizationState state) {
    final sentence = state.currentSentence;
    final words = sentence.split(RegExp(r'\s+'));
    final highlightedIndex = state.highlightedWordIndex;

    final spans = <TextSpan>[];
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      spans.add(TextSpan(
        text: word + (i < words.length - 1 ? ' ' : ''),
        style: TextStyle(
          fontSize: 18,
          fontWeight: i == highlightedIndex ? FontWeight.bold : FontWeight.normal,
          color: i == highlightedIndex
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          backgroundColor: i == highlightedIndex
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildAudioPhase(MemorizationState state) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.volume_up,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Audio Induction Phase',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Repeat ${state.repeatCount}/3',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Playing audio...'),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingPhase(MemorizationState state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Recall Phase',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TypingValidationWidget(
              expectedText: state.currentSentence,
              onChanged: (typed, isComplete) {
                if (isComplete) {
                  _completeCurrentSentence();
                }
              },
              onMistake: (expected, entered, errorIndex) {
                // Mistakes are handled by the provider
              },
              enabled: !state.isPlaying,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(MemorizationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: state.isPlaying ? null : () => _playCurrentSentence(),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Play Audio'),
        ),
        ElevatedButton.icon(
          onPressed: () => _skipToNext(),
          icon: const Icon(Icons.skip_next),
          label: const Text('Skip'),
        ),
      ],
    );
  }

  void _playCurrentSentence() {
    ref.read(memorizationProvider.notifier).playCurrentSentence();
  }

  void _completeCurrentSentence() {
    ref.read(memorizationProvider.notifier).completeCurrentSentence();
  }

  void _skipToNext() {
    ref.read(memorizationProvider.notifier).completeCurrentSentence();
  }

  void _toggleTranslation() {
    ref.read(memorizationProvider.notifier).toggleTranslation();
  }

  void _retrainErrors() {
    ref.read(memorizationProvider.notifier).retrainErrors();
  }
}