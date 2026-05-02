import '../models/lecture.dart';
import '../models/user_progress.dart';
import '../models/mistake.dart';
import '../core/study_engine.dart';

class StudySessionService {
  static List<int> getActiveSentenceIndexes({
    required Lecture lecture,
    required List<String> sentences,
    required bool retryWrongOnly,
    required List<UserProgress> progressItems,
    required List<Mistake> mistakes,
  }) {
    return StudyEngine.activeSentenceIndexes(
      sentences: sentences,
      retryOnly: retryWrongOnly,
      mistakes: mistakes,
      progressItems: progressItems,
      lectureId: lecture.id,
    );
  }

  static double calculateSessionProgress({
    required List<int> activeIndexes,
    required int currentIndex,
  }) {
    if (activeIndexes.isEmpty) return 0.0;
    return (currentIndex + 1) / activeIndexes.length;
  }

  static Map<String, dynamic> getSessionStats({
    required Lecture lecture,
    required List<UserProgress> progressItems,
    required List<Mistake> mistakes,
  }) {
    final lectureProgress = progressItems.firstWhere(
      (p) => p.lectureId == lecture.id,
      orElse: () => UserProgress(
        id: 'temp_${lecture.id}',
        lectureId: lecture.id,
        progress: 0.0,
        lastStudied: DateTime.now(),
        mistakesCount: 0,
        sentenceAccuracies: {},
      ),
    );

    final accuracies = lectureProgress.sentenceAccuracies;
    final avgAccuracy = accuracies?.values.isNotEmpty == true
        ? accuracies!.values.reduce((a, b) => a + b) / accuracies.length
        : 0.0;

    final mistakeCount = mistakes.where((m) => m.lectureId == lecture.id).length;

    return {
      'averageAccuracy': avgAccuracy,
      'totalMistakes': mistakeCount,
      'sentencesStudied': accuracies?.length ?? 0,
    };
  }
}