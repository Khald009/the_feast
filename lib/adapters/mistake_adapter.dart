import 'package:hive/hive.dart';
import '../models/mistake.dart';

class MistakeAdapter extends TypeAdapter<Mistake> {
  @override
  final int typeId = 3;

  @override
  Mistake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mistake(
      id: fields[0] as String,
      lectureId: fields[1] as String,
      description: fields[2] as String,
      correction: fields[3] as String?,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Mistake obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lectureId)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.correction)
      ..writeByte(4)
      ..write(obj.date);
  }
}
