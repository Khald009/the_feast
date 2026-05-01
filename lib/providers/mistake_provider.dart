import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mistake.dart';
import 'hive_state_notifier.dart';

class MistakeNotifier extends HiveStateNotifier<Mistake> {
  @override
  String get boxName => 'mistakes';

  @override
  String getId(Mistake item) => item.id;

  Future<void> addMistake(Mistake mistake) => addItem(mistake);

  Future<void> deleteMistake(String id) => deleteItem(id);

  List<Mistake> getMistakesByLecture(String lectureId) {
    return state.where((m) => m.lectureId == lectureId).toList();
  }
}

final mistakeProvider = StateNotifierProvider<MistakeNotifier, List<Mistake>>(
  (ref) => MistakeNotifier(),
);