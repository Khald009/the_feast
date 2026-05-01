import 'package:hive/hive.dart';
import '../models/lecture.dart';

class LectureAdapter extends TypeAdapter<Lecture> {
  @override
  final int typeId = 1;

  @override
  Lecture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lecture(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      title: fields[2] as String,
      contentIds: List<String>.from(fields[3] as List),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Lecture obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.contentIds)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
