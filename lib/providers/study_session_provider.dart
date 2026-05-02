import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_processing_service.dart';
import '../core/tts_service.dart';
import '../core/translation_service.dart';
import '../core/study_session_service.dart';
import '../models/lecture.dart';
import '../models/user_progress.dart';
import '../models/mistake.dart';
import 'service_providers.dart';

enum StudyMode { explanation, memorization, translation }

enum RetrainMode { all, wrongOnly }

class StudySessionState {
  final StudyMode mode;
  final RetrainMode retrainMode;
  final String currentSentence;
  final String typedAnswer;
  final bool isSubmitting;
  final double accuracy;
  final bool isSpeaking;
  final int currentWordIndex;
  final List<int> activeSentenceIndexes;
  final int currentSentenceIndex;
  final Map<String, dynamic> sessionStats;

  const StudySessionState({
    this.mode = StudyMode.explanation,
    this.retrainMode = RetrainMode.all,
    this.currentSentence = '',
    this.typedAnswer = '',
    this.isSubmitting = false,
    this.accuracy = 0.0,
    this.isSpeaking = false,
    this.currentWordIndex = -1,
    this.activeSentenceIndexes = const [],
    this.currentSentenceIndex = 0,
    this.sessionStats = const {},
  });

  StudySessionState copyWith({
    StudyMode? mode,
    RetrainMode? retrainMode,
    String? currentSentence,
    String? typedAnswer,
    bool? isSubmitting,
    double? accuracy,
    bool? isSpeaking,
    int? currentWordIndex,
    List<int>? activeSentenceIndexes,
    int? currentSentenceIndex,
    Map<String, dynamic>? sessionStats,
  }) {
    return StudySessionState(
      mode: mode ?? this.mode,
      retrainMode: retrainMode ?? this.retrainMode,
      currentSentence: currentSentence ?? this.currentSentence,
      typedAnswer: typedAnswer ?? this.typedAnswer,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      accuracy: accuracy ?? this.accuracy,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      activeSentenceIndexes: activeSentenceIndexes ?? this.activeSentenceIndexes,
      currentSentenceIndex: currentSentenceIndex ?? this.currentSentenceIndex,
      sessionStats: sessionStats ?? this.sessionStats,
    );
  }
}

class StudySessionNotifier extends StateNotifier<StudySessionState> {
  final AIProcessingService aiService;
  final TTSService ttsService;
  final TranslationService translationService;

  StudySessionNotifier({
    required this.aiService,
    required this.ttsService,
    required this.translationService,
  }) : super(const StudySessionState());

  void initializeSession({
    required Lecture lecture,
    required List<String> sentences,
    required List<UserProgress> progressItems,
    required List<Mistake> mistakes,
  }) {
    final activeIndexes = StudySessionService.getActiveSentenceIndexes(
      lecture: lecture,
      sentences: sentences,
      retryWrongOnly: state.retrainMode == RetrainMode.wrongOnly,
      progressItems: progressItems,
      mistakes: mistakes,
    );

    final stats = StudySessionService.getSessionStats(
      lecture: lecture,
      progressItems: progressItems,
      mistakes: mistakes,
    );

    state = state.copyWith(
      activeSentenceIndexes: activeIndexes,
      sessionStats: stats,
      currentSentenceIndex: 0,
      currentSentence: sentences.isNotEmpty ? sentences[activeIndexes.first] : '',
    );
  }

  void setMode(StudyMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setRetrainMode(RetrainMode retrainMode) {
    state = state.copyWith(retrainMode: retrainMode);
  }

  void setCurrentSentence(String sentence) {
    state = state.copyWith(
        currentSentence: sentence, typedAnswer: '', accuracy: 0.0);
  }

  void setTypedAnswer(String input) {
    state = state.copyWith(typedAnswer: input);
  }

  void nextSentence(List<String> sentences) {
    final nextIndex = state.currentSentenceIndex + 1;
    if (nextIndex < state.activeSentenceIndexes.length) {
      final sentenceIndex = state.activeSentenceIndexes[nextIndex];
      state = state.copyWith(
        currentSentenceIndex: nextIndex,
        currentSentence: sentences[sentenceIndex],
        typedAnswer: '',
        accuracy: 0.0,
      );
    }
  }

  void previousSentence(List<String> sentences) {
    final prevIndex = state.currentSentenceIndex - 1;
    if (prevIndex >= 0) {
      final sentenceIndex = state.activeSentenceIndexes[prevIndex];
      state = state.copyWith(
        currentSentenceIndex: prevIndex,
        currentSentence: sentences[sentenceIndex],
        typedAnswer: '',
        accuracy: 0.0,
      );
    }
  }

  Future<void> speakSentence() async {
    if (!ttsService.isAvailable) return;
    await ttsService.speak(state.currentSentence);
  }

  Future<void> speakSentenceWithProgress(
      void Function(int wordIndex) onWordSpoken) async {
    if (!ttsService.isAvailable || state.currentSentence.isEmpty) return;

    state = state.copyWith(isSpeaking: true, currentWordIndex: -1);
    try {
      await ttsService.speakWithProgress(state.currentSentence, (wordIndex) {
        state = state.copyWith(currentWordIndex: wordIndex);
        onWordSpoken(wordIndex);
      });
    } finally {
      state = state.copyWith(isSpeaking: false, currentWordIndex: -1);
    }
  }

  void stopSpeaking() {
    ttsService.stop();
    state = state.copyWith(isSpeaking: false, currentWordIndex: -1);
  }

  Future<String> translateSentence(String toLocale) async {
    return translationService.translate(state.currentSentence, 'ar', toLocale);
  }
}

final studySessionProvider =
    StateNotifierProvider<StudySessionNotifier, StudySessionState>(
  (ref) => StudySessionNotifier(
    aiService: MockAIProcessingService(), // Temporary fallback
    ttsService: ref.read(ttsServiceProvider),
    translationService: ref.read(translationServiceProvider),
  ),
);

// Future provider that creates the notifier with real AI service
final studySessionProviderAsync = FutureProvider<StudySessionNotifier>((ref) async {
  final aiService = await ref.watch(aiProcessingServiceProvider.future);
  return StudySessionNotifier(
    aiService: aiService,
    ttsService: ref.read(ttsServiceProvider),
    translationService: ref.read(translationServiceProvider),
  );
});
