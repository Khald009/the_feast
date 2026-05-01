import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import 'hive_state_notifier.dart';

class UserProgressNotifier extends HiveStateNotifier<UserProgress> {
  @override
  String get boxName => 'userProgress';

  @override
  String getId(UserProgress item) => item.id;

  UserProgress? getProgressForLecture(String lectureId) {
    final progress = state.where((progress) => progress.lectureId == lectureId).toList();
    return progress.isEmpty ? null : progress.first;
  }

  Future<void> _saveProgress(UserProgress progress) async {
    final box = await boxFuture;
    await box.put(progress.id, progress);
    state = [...state.where((p) => p.id != progress.id), progress];
  }

  Future<void> updateProgress(String lectureId, double increment) async {
    final existing = getProgressForLecture(lectureId);
    final progress = existing ?? UserProgress(
      id: lectureId,
      lectureId: lectureId,
      progress: 0.0,
      lastStudied: DateTime.now(),
      mistakesCount: 0,
    );
    final updated = progress.copyWith(
      progress: (progress.progress + increment).clamp(0.0, 1.0),
      lastStudied: DateTime.now(),
    );
    await _saveProgress(updated);
  }

  Future<void> setProgress(String lectureId, double value) async {
    final existing = getProgressForLecture(lectureId);
    final progress = existing ?? UserProgress(
      id: lectureId,
      lectureId: lectureId,
      progress: 0.0,
      lastStudied: DateTime.now(),
      mistakesCount: 0,
    );
    final updated = progress.copyWith(
      progress: value.clamp(0.0, 1.0),
      lastStudied: DateTime.now(),
    );
    await _saveProgress(updated);
  }

  Future<void> trackAccuracy(String lectureId, String sentence, double accuracy) async {
    final existing = getProgressForLecture(lectureId);
    final progress = existing ?? UserProgress(
      id: lectureId,
      lectureId: lectureId,
      progress: 0.0,
      lastStudied: DateTime.now(),
      mistakesCount: 0,
    );

    final sentenceAccuracies = progress.sentenceAccuracies ?? {};
    sentenceAccuracies[sentence] = accuracy;

    final updated = progress.copyWith(
      lastAccuracy: accuracy,
      totalAttempts: progress.totalAttempts + 1,
      sentenceAccuracies: sentenceAccuracies,
      lastStudied: DateTime.now(),
    );
    await _saveProgress(updated);
  }
}

final userProgressProvider = StateNotifierProvider<UserProgressNotifier, List<UserProgress>>(
  (ref) => UserProgressNotifier(),
);