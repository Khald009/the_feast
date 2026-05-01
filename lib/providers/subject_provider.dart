import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';
import 'hive_state_notifier.dart';

class SubjectNotifier extends HiveStateNotifier<Subject> {
  @override
  String get boxName => 'subjects';

  @override
  String getId(Subject item) => item.id;

  Future<void> addSubject(Subject subject) => addItem(subject);

  Future<void> updateSubject(String id, Subject updatedSubject) => updateItem(updatedSubject);

  Future<void> deleteSubject(String id) => deleteItem(id);
}

final subjectProvider = StateNotifierProvider<SubjectNotifier, List<Subject>>(
  (ref) => SubjectNotifier(),
);