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
      lectureNumber: fields[2] as int? ?? 1,
      lectureName: fields[3] as String? ?? '',
      sourceContent: fields[4] as String? ?? '',
      contentIds: List<String>.from(fields[5] as List? ?? []),
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Lecture obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.lectureNumber)
      ..writeByte(3)
      ..write(obj.lectureName)
      ..writeByte(4)
      ..write(obj.sourceContent)
      ..writeByte(5)
      ..write(obj.contentIds)
      ..writeByte(6)
      ..write(obj.createdAt);
  }
}
