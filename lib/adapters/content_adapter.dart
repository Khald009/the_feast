import 'package:hive/hive.dart';
import '../models/content.dart';

class ContentAdapter extends TypeAdapter<Content> {
  @override
  final int typeId = 2;

  @override
  Content read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Content(
      id: fields[0] as String,
      lectureId: fields[1] as String,
      type: ContentType.values[fields[2] as int],
      data: fields[3] as String,
      metadata: fields[4] as Map<String, dynamic>?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Content obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lectureId)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.metadata)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}