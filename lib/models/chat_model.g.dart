// chat_model.g.dart
// Adaptateur Hive pour ChatModel — généré manuellement.
// Permet à Hive de sérialiser/désérialiser les objets ChatModel.

part of 'chat_model.dart';

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  final int typeId = 3; // Correspond au @HiveType(typeId: 3)

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      id: fields[0] as String,
      participantIds: (fields[1] as List).cast<String>(),
      name: fields[2] as String?,
      lastMessageContent: fields[3] as String?,
      lastActivity: fields[4] as DateTime,
      unreadCount: fields[5] as int,
      isGroup: fields[6] as bool,
      lastMessageSenderId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.participantIds)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.lastMessageContent)
      ..writeByte(4)
      ..write(obj.lastActivity)
      ..writeByte(5)
      ..write(obj.unreadCount)
      ..writeByte(6)
      ..write(obj.isGroup)
      ..writeByte(7)
      ..write(obj.lastMessageSenderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
