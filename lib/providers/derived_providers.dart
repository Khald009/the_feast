import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lecture.dart';
import '../models/mistake.dart';
import '../models/user_progress.dart';
import '../models/content.dart';
import 'lecture_provider.dart';
import 'mistake_provider.dart';
import 'user_progress_provider.dart';
import 'content_provider.dart';

/// Provides a filtered list of lectures by subject ID
/// Input: subjectId
/// Output: List of lectures for that subject
final lecturesBySubjectProvider =
    Provider.family<List<Lecture>, String>((ref, subjectId) {
  final allLectures = ref.watch(lectureProvider);
  return allLectures
      .where((lecture) => lecture.subjectId == subjectId)
      .toList();
});

/// Provides the progress for a specific lecture
/// Input: lectureId
/// Output: UserProgress for that lecture, or null if not found
final lectureProgressProvider =
    Provider.family<UserProgress?, String>((ref, lectureId) {
  final allProgress = ref.watch(userProgressProvider);
  try {
    return allProgress.firstWhere((p) => p.lectureId == lectureId);
  } on StateError {
    return null;
  }
});

/// Provides a filtered list of mistakes by lecture ID
/// Input: lectureId
/// Output: List of mistakes for that lecture
final lectureMistakesProvider =
    Provider.family<List<Mistake>, String>((ref, lectureId) {
  final allMistakes = ref.watch(mistakeProvider);
  return allMistakes.where((m) => m.lectureId == lectureId).toList();
});

/// Provides all contents for a specific lecture
/// Input: lectureId
/// Output: List of all contents for that lecture
final contentsByLectureProvider =
    Provider.family<List<Content>, String>((ref, lectureId) {
  final allContents = ref.watch(contentProvider);
  return allContents.where((c) => c.lectureId == lectureId).toList();
});

/// Provides only text contents for a specific lecture
/// Input: lectureId
/// Output: List of text contents for that lecture
final textContentsByLectureProvider =
    Provider.family<List<Content>, String>((ref, lectureId) {
  final allContents = ref.watch(contentProvider);
  return allContents
      .where((c) => c.lectureId == lectureId && c.type == ContentType.text)
      .toList();
});

/// Provides extracted sentences from text contents of a lecture
/// Input: lectureId
/// Output: List of sentences split from text contents
final studySentencesProvider =
    Provider.family<List<String>, String>((ref, lectureId) {
  final textContents = ref.watch(textContentsByLectureProvider(lectureId));

  // Build sentences from text contents
  final rawText = textContents
      .map((content) => content.data.trim())
      .where((text) => text.isNotEmpty)
      .join(' ');

  // Split by sentence delimiters and clean up
  final split = rawText.split(RegExp(r'(?<=[.!?])\s+'));
  return split
      .map((sentence) => sentence.trim())
      .where((sentence) => sentence.isNotEmpty)
      .toList();
});
