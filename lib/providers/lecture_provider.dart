import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lecture.dart';
import 'hive_state_notifier.dart';

class LectureNotifier extends HiveStateNotifier<Lecture> {
  @override
  String get boxName => 'lectures';

  @override
  String getId(Lecture item) => item.id;

  Future<void> addLecture(Lecture lecture) => addItem(lecture);

  Future<void> updateLecture(String id, Lecture updatedLecture) => updateItem(updatedLecture);

  Future<void> deleteLecture(String id) => deleteItem(id);

  List<Lecture> getLecturesBySubject(String subjectId) {
    return state.where((l) => l.subjectId == subjectId).toList();
  }
}

final lectureProvider = StateNotifierProvider<LectureNotifier, List<Lecture>>(
  (ref) => LectureNotifier(),
);