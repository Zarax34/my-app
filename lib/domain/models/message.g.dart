// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// HiveGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 1;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      role: fields[1] as MessageRole,
      content: fields[2] as String,
      timestamp: fields[3] as DateTime,
      conversationId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.conversationId);
  }
}

class MessageRoleAdapter extends TypeAdapter<MessageRole> {
  @override
  final int typeId = 0;

  @override
  MessageRole read(BinaryReader reader) {
    return MessageRole.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, MessageRole obj) {
    writer.writeByte(obj.index);
  }
}
