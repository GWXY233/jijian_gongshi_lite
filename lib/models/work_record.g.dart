// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkRecordAdapter extends TypeAdapter<WorkRecord> {
  @override
  final int typeId = 0;

  @override
  WorkRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      startMinutes: fields[2] as int,
      endMinutes: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.startMinutes)
      ..writeByte(3)
      ..write(obj.endMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
