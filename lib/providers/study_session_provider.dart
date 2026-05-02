import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai_processing_service.dart';
import '../core/tts_service.dart';
import '../core/translation_service.dart';
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

  const StudySessionState({
    this.mode = StudyMode.explanation,
    this.retrainMode = RetrainMode.all,
    this.currentSentence = '',
    this.typedAnswer = '',
    this.isSubmitting = false,
    this.accuracy = 0.0,
    this.isSpeaking = false,
    this.currentWordIndex = -1,
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
    aiService: ref.read(aiProcessingServiceProvider),
    ttsService: ref.read(ttsServiceProvider),
    translationService: ref.read(translationServiceProvider),
  ),
);
