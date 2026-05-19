/// ============================================================
/// message_model.g.dart
/// Fichier généré manuellement pour Hive (normalement généré par
/// build_runner, mais on le crée à la main pour éviter la dépendance
/// à hive_generator en dev rapide).
/// ============================================================

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

/// Adaptateur Hive pour MessageModel
/// Hive utilise ces adaptateurs pour sérialiser/désérialiser les objets
class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 0; // Doit correspondre au @HiveType(typeId: 0)

  @override
  MessageModel read(BinaryReader reader) {
    // Lit les champs dans l'ordre des @HiveField
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      senderId: fields[1] as String,
      receiverId: fields[2] as String,
      chatId: fields[3] as String,
      content: fields[4] as String,
      type: fields[5] as MessageType,
      timestamp: fields[6] as DateTime,
      status: fields[7] as MessageStatus,
      mediaUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    // Écrit les champs dans l'ordre des @HiveField
    writer
      ..writeByte(9) // Nombre de champs
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.receiverId)
      ..writeByte(3)
      ..write(obj.chatId)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.mediaUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adaptateur Hive pour l'enum MessageType
class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 1;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.video;
      case 3:
        return MessageType.file;
      case 4:
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Adaptateur Hive pour l'enum MessageStatus
class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 2;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sending;
      case 1:
        return MessageStatus.sent;
      case 2:
        return MessageStatus.delivered;
      case 3:
        return MessageStatus.read;
      case 4:
        return MessageStatus.failed;
      default:
        return MessageStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
