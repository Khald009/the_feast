import 'package:hive/hive.dart';
import '../models/user_progress.dart';

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 4;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      id: fields[0] as String,
      lectureId: fields[1] as String,
      progress: fields[2] as double,
      lastStudied: fields[3] as DateTime,
      mistakesCount: fields[4] as int,
      lastAccuracy: fields[5] as double? ?? 0.0,
      totalAttempts: fields[6] as int? ?? 0,
      sentenceAccuracies: fields[7] as Map<String, dynamic>?,
      additionalData: fields[8] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lectureId)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.lastStudied)
      ..writeByte(4)
      ..write(obj.mistakesCount)
      ..writeByte(5)
      ..write(obj.lastAccuracy)
      ..writeByte(6)
      ..write(obj.totalAttempts)
      ..writeByte(7)
      ..write(obj.sentenceAccuracies)
      ..writeByte(8)
      ..write(obj.additionalData);
  }
}

