import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weak_point.dart';
import 'hive_state_notifier.dart';

class WeakPointNotifier extends HiveStateNotifier<WeakPoint> {
  @override
  String get boxName => 'weak_points';

  @override
  String getId(WeakPoint item) => item.id;

  Future<void> addWeakPoint(WeakPoint weakPoint) => addItem(weakPoint);

  Future<void> updateWeakPoint(WeakPoint weakPoint) => updateItem(weakPoint);

  Future<void> deleteWeakPoint(String id) => deleteItem(id);

  List<WeakPoint> getWeakPointsByLecture(String lectureId) {
    return state.where((point) => point.lectureId == lectureId).toList();
  }

  List<WeakPoint> getWeakPointsBySentence(String lectureId, String sentence) {
    return state
        .where((point) =>
            point.lectureId == lectureId && point.sentence == sentence)
        .toList();
  }
}

final weakPointProvider =
    StateNotifierProvider<WeakPointNotifier, List<WeakPoint>>(
  (ref) => WeakPointNotifier(),
);
