/// Abstract interfaces for extensible study features.
/// These define contracts for future features without implementing them yet.
library study_extensions;

/// Interface for AI-powered explanations of study content
abstract class AIExplainer {
  /// Generate an explanation for a given sentence
  /// Returns null if explanation cannot be generated
  Future<String?> explainSentence(String sentence);

  /// Generate hints for memorization practice
  /// Returns null if hints cannot be generated
  Future<String?> generateHints(String sentence);
}

/// Interface for voice and audio features
abstract class VoiceProvider {
  /// Play audio for a sentence (e.g., pronunciation)
  Future<void> playSentence(String sentence);

  /// Record user pronunciation and get feedback
  Future<VoiceRecordingResult?> recordAndAnalyze(String sentence);

  /// Check if voice features are available
  bool get isVoiceAvailable;
}

/// Result of voice recording analysis
class VoiceRecordingResult {
  final String recordingPath;
  final double pronunciationScore; // 0.0 to 1.0
  final List<String> mistakeWords;

  VoiceRecordingResult({
    required this.recordingPath,
    required this.pronunciationScore,
    required this.mistakeWords,
  });
}

/// Interface for translation and multilingual support
abstract class TranslationProvider {
  /// Translate a sentence to the target language
  /// Returns null if translation cannot be generated
  Future<String?> translate(String sentence, String targetLanguage);

  /// Get available target languages
  Future<List<String>> getAvailableLanguages();
}

/// Study session configuration for extensibility
class StudySessionConfig {
  /// Enable AI explanations if available
  final bool enableAIExplanations;

  /// Enable voice features if available
  final bool enableVoicePlayback;

  /// Enable translations if available
  final bool enableTranslations;

  /// Target language for translations (e.g., 'en', 'es', 'fr')
  final String? targetLanguage;

  const StudySessionConfig({
    this.enableAIExplanations = false,
    this.enableVoicePlayback = false,
    this.enableTranslations = false,
    this.targetLanguage,
  });
}
