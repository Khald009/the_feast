import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content.dart';
import 'hive_state_notifier.dart';

class ContentNotifier extends HiveStateNotifier<Content> {
  @override
  String get boxName => 'contents';

  @override
  String getId(Content item) => item.id;

  Future<void> addContent(Content content) => addItem(content);

  Future<void> updateContent(String id, Content updatedContent) => updateItem(updatedContent);

  Future<void> deleteContent(String id) => deleteItem(id);

  List<Content> getContentsByLecture(String lectureId) {
    return state.where((c) => c.lectureId == lectureId).toList();
  }

  List<Content> getContentsBySubject(String subjectId, List<String> lectureIds) {
    return state.where((c) => lectureIds.contains(c.lectureId)).toList();
  }
}

final contentProvider = StateNotifierProvider<ContentNotifier, List<Content>>(
  (ref) => ContentNotifier(),
);