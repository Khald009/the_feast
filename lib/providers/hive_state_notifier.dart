import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

abstract class HiveStateNotifier<T> extends StateNotifier<List<T>> {
  late final Future<Box<T>> _boxFuture;

  HiveStateNotifier() : super([]) {
    _boxFuture = Hive.openBox<T>(boxName);
    _loadFromBox();
  }

  String get boxName;

  Future<Box<T>> get boxFuture async => _boxFuture;

  Future<void> _loadFromBox() async {
    final box = await boxFuture;
    state = box.values.toList();
  }

  String getId(T item);

  Future<void> addItem(T item) async {
    final box = await boxFuture;
    await box.put(getId(item), item);
    state = [...state, item];
  }

  Future<void> updateItem(T item) async {
    final box = await boxFuture;
    await box.put(getId(item), item);
    state = state.map((value) => getId(value) == getId(item) ? item : value).toList();
  }

  Future<void> deleteItem(String id) async {
    final box = await boxFuture;
    await box.delete(id);
    state = state.where((value) => getId(value) != id).toList();
  }
}
