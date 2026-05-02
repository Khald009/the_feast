import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/ai_processing_service.dart';
import '../models/weak_point.dart';
import '../models/lecture.dart';
import 'service_providers.dart';
import 'weak_point_provider.dart';

enum MemorizationMode {
  normal,
  remedial,
}

class MemorizationState {
  final String lectureId;
  final List<String> sentences;
  final int currentSentenceIndex;
  final int repeatCount;
  final bool isPlaying;
  final bool translationEnabled;
  final String translatedSentence;
  final int highlightedWordIndex;
  final String typedText;
  final MemorizationMode mode;
  final List<WeakPoint> weakPoints;
  final String currentSentence;

  const MemorizationState({
    required this.lectureId,
    required this.sentences,
    required this.currentSentenceIndex,
    required this.repeatCount,
    required this.isPlaying,
    required this.translationEnabled,
    required this.translatedSentence,
    required this.highlightedWordIndex,
    required this.typedText,
    required this.mode,
    required this.weakPoints,
    required this.currentSentence,
  });

  factory MemorizationState.initial() {
    return const MemorizationState(
      lectureId: '',
      sentences: [],
      currentSentenceIndex: 0,
      repeatCount: 0,
      isPlaying: false,
      translationEnabled: false,
      translatedSentence: '',
      highlightedWordIndex: 0,
      typedText: '',
      mode: MemorizationMode.normal,
      weakPoints: [],
      currentSentence: '',
    );
  }

  MemorizationState copyWith({
    String? lectureId,
    List<String>? sentences,
    int? currentSentenceIndex,
    int? repeatCount,
    bool? isPlaying,
    bool? translationEnabled,
    String? translatedSentence,
    int? highlightedWordIndex,
    String? typedText,
    MemorizationMode? mode,
    List<WeakPoint>? weakPoints,
    String? currentSentence,
  }) {
    return MemorizationState(
      lectureId: lectureId ?? this.lectureId,
      sentences: sentences ?? this.sentences,
      currentSentenceIndex: currentSentenceIndex ?? this.currentSentenceIndex,
      repeatCount: repeatCount ?? this.repeatCount,
      isPlaying: isPlaying ?? this.isPlaying,
      translationEnabled: translationEnabled ?? this.translationEnabled,
      translatedSentence: translatedSentence ?? this.translatedSentence,
      highlightedWordIndex: highlightedWordIndex ?? this.highlightedWordIndex,
      typedText: typedText ?? this.typedText,
      mode: mode ?? this.mode,
      weakPoints: weakPoints ?? this.weakPoints,
      currentSentence: currentSentence ?? this.currentSentence,
    );
  }
}

class MemorizationNotifier extends AsyncNotifier<MemorizationState> {
  late final FlutterTts _tts;
  final _wordBoundaries = <String>[];

  @override
  Future<MemorizationState> build() async {
    _tts = FlutterTts();
    _configureTts();
    return MemorizationState.initial();
  }

  void _configureTts() {
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
    _tts.setStartHandler(() {
      state = AsyncData(state.value!.copyWith(isPlaying: true));
    });
    _tts.setCompletionHandler(() {
      state = AsyncData(state.value!.copyWith(isPlaying: false, highlightedWordIndex: 0));
    });
    _tts.setErrorHandler((message) {
      state = AsyncData(state.value!.copyWith(isPlaying: false));
    });
    _tts.setProgressHandler((String? text, int start, int end, String word) {
      final currentSentence = state.value?.currentSentence ?? '';
      _wordBoundaries.clear();
      _wordBoundaries.addAll(currentSentence.split(RegExp(r'\s+')));
      final currentIndex = _wordBoundaries
          .indexWhere((w) => w.isNotEmpty && text != null && text.contains(w));
      state = AsyncData(state.value!
          .copyWith(highlightedWordIndex: currentIndex < 0 ? 0 : currentIndex));
    });
  }

  Future<void> initializeSession({
    required Lecture lecture,
    required List<String> sentences,
    MemorizationMode mode = MemorizationMode.normal,
  }) async {
    final filteredSentences = mode == MemorizationMode.remedial
        ? await _buildRemedialQueue(lecture.id, sentences)
        : sentences;

    state = AsyncData(
      state.value!.copyWith(
        lectureId: lecture.id,
        sentences: filteredSentences,
        currentSentenceIndex: 0,
        repeatCount: 0,
        mode: mode,
        currentSentence:
            filteredSentences.isNotEmpty ? filteredSentences.first : '',
        translatedSentence: '',
        typedText: '',
        highlightedWordIndex: 0,
      ),
    );
  }

  Future<void> setSentences(List<String> sentences) async {
    state = AsyncData(
      state.value!.copyWith(
        sentences: sentences,
        currentSentenceIndex: 0,
        repeatCount: 0,
        currentSentence: sentences.isNotEmpty ? sentences.first : '',
        typedText: '',
        highlightedWordIndex: 0,
      ),
    );
  }

  Future<void> toggleTranslation({String targetLanguage = 'Arabic'}) async {
    final current = state.value!;
    if (!current.translationEnabled) {
      final translated =
          await _translateText(current.currentSentence, targetLanguage);
      state = AsyncData(current.copyWith(
        translationEnabled: true,
        translatedSentence: translated,
      ));
    } else {
      state = AsyncData(current.copyWith(
        translationEnabled: false,
        translatedSentence: '',
      ));
    }
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    try {
      final AIProcessingService aiService = await ref.read(aiProcessingServiceProvider.future);
      return await aiService.translateText(text, targetLanguage);
    } catch (_) {
      return text;
    }
  }

  Future<void> playCurrentSentence({String languageCode = 'en-US'}) async {
    final current = state.value!;
    if (current.currentSentence.isEmpty) return;

    final sentence = current.currentSentence;
    await _tts.setLanguage(languageCode);
    await _tts.stop();

    for (var repeat = current.repeatCount + 1; repeat <= 3; repeat++) {
      state = AsyncData(current.copyWith(repeatCount: repeat, isPlaying: true));
      await _tts.speak(sentence);
      await Future.delayed(const Duration(milliseconds: 300));
    }

    final nextIndex = current.currentSentenceIndex + 1;
    final nextSentence = nextIndex < current.sentences.length
        ? current.sentences[nextIndex]
        : '';
    state = AsyncData(current.copyWith(
      currentSentenceIndex: nextIndex < current.sentences.length
          ? nextIndex
          : current.currentSentenceIndex,
      repeatCount: 0,
      currentSentence: nextSentence,
      typedText: '',
      highlightedWordIndex: 0,
      isPlaying: false,
    ));
  }

  void onTypingChanged(String typed) {
    final current = state.value!;
    final expected = current.currentSentence;
    var correct = true;
    var mistakeWord = '';
    var mistakeCharacter = '';

    for (var i = 0; i < typed.length; i++) {
      if (i >= expected.length || typed[i] != expected[i]) {
        correct = false;
        mistakeCharacter = typed[i];
        final words = expected.split(RegExp(r'\s+'));
        final charIndex = typed.length - 1;
        var cumulative = 0;
        for (final word in words) {
          if (charIndex < cumulative + word.length) {
            mistakeWord = word;
            break;
          }
          cumulative += word.length + 1;
        }
        break;
      }
    }

    if (!correct && typed.isNotEmpty) {
      HapticFeedback.mediumImpact();
      _logWeakPoint(current.lectureId, expected, mistakeWord, mistakeCharacter);
    }

    state = AsyncData(current.copyWith(typedText: typed));
  }

  Future<void> completeCurrentSentence() async {
    final current = state.value!;
    if (current.typedText.trim() == current.currentSentence.trim()) {
      final nextIndex = current.currentSentenceIndex + 1;
      final nextSentence = nextIndex < current.sentences.length
          ? current.sentences[nextIndex]
          : '';
      state = AsyncData(current.copyWith(
        currentSentenceIndex: nextIndex < current.sentences.length
            ? nextIndex
            : current.currentSentenceIndex,
        currentSentence: nextSentence,
        typedText: '',
        highlightedWordIndex: 0,
        repeatCount: 0,
      ));
    }
  }

  Future<void> retrainErrors() async {
    final current = state.value!;
    final filtered =
        current.weakPoints.map((point) => point.sentence).toSet().toList();
    state = AsyncData(current.copyWith(
      sentences: filtered,
      currentSentenceIndex: 0,
      currentSentence: filtered.isNotEmpty ? filtered.first : '',
      repeatCount: 0,
      mode: MemorizationMode.remedial,
      typedText: '',
    ));
  }

  Future<void> _logWeakPoint(
    String lectureId,
    String sentence,
    String word,
    String character,
  ) async {
    if (word.isEmpty && character.isEmpty) return;
    final weakPointNotifier = ref.read(weakPointProvider.notifier);
    final existing =
        weakPointNotifier.getWeakPointsBySentence(lectureId, sentence);
    final match = existing.firstWhere(
      (item) => item.word == word && item.character == character,
      orElse: () => WeakPoint(
        id: '',
        lectureId: lectureId,
        sentence: sentence,
        word: word,
        character: character,
        mistakeCount: 0,
        lastReviewed: DateTime.now(),
      ),
    );

    if (match.id.isNotEmpty) {
      final updated = match.copyWith(
        mistakeCount: match.mistakeCount + 1,
        lastReviewed: DateTime.now(),
      );
      await weakPointNotifier.updateWeakPoint(updated);
      state = AsyncData(state.value!.copyWith(
        weakPoints: [
          for (final point in state.value!.weakPoints)
            if (point.id == updated.id) updated else point,
        ],
      ));
    } else {
      final newPoint = WeakPoint(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lectureId: lectureId,
        sentence: sentence,
        word: word,
        character: character,
        mistakeCount: 1,
        lastReviewed: DateTime.now(),
      );
      await weakPointNotifier.addWeakPoint(newPoint);
      state = AsyncData(state.value!.copyWith(
        weakPoints: [...state.value!.weakPoints, newPoint],
      ));
    }
  }

  Future<List<String>> _buildRemedialQueue(
      String lectureId, List<String> sentences) async {
    final weakPoints = ref
        .read(weakPointProvider)
        .where((point) => point.lectureId == lectureId)
        .toList();
    final remedialSentences = <String>[];
    for (final sentence in sentences) {
      if (weakPoints.any((point) => point.sentence == sentence)) {
        remedialSentences.add(sentence);
      }
    }
    return remedialSentences.isEmpty ? sentences : remedialSentences;
  }
}

final memorizationProvider =
    AsyncNotifierProvider<MemorizationNotifier, MemorizationState>(
  () => MemorizationNotifier(),
);
