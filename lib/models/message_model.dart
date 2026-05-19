/// ============================================================
/// message_model.dart
/// Modèle de données représentant un message dans NovaX.
/// Annoté avec @HiveType pour la persistance locale via Hive.
/// ============================================================

import 'package:hive/hive.dart';

// Indique à Hive que cette classe peut être stockée localement.
// typeId doit être unique pour chaque classe Hive dans le projet.
part 'message_model.g.dart';

/// Types de messages supportés par NovaX
@HiveType(typeId: 1) // typeId: 1 = MessageType dans Hive
enum MessageType {
  @HiveField(0)
  text, // Message texte simple
  @HiveField(1)
  image, // Image envoyée
  @HiveField(2)
  video, // Vidéo envoyée
  @HiveField(3)
  file, // Fichier quelconque
  @HiveField(4)
  voice, // Message vocal
}

/// Statut de livraison d'un message (comme les coches WhatsApp)
@HiveType(typeId: 2) // typeId: 2 = MessageStatus dans Hive
enum MessageStatus {
  @HiveField(0)
  sending, // ⏳ En cours d'envoi
  @HiveField(1)
  sent, // ✓  Envoyé au serveur
  @HiveField(2)
  delivered, // ✓✓ Reçu par le destinataire
  @HiveField(3)
  read, // ✓✓ Lu par le destinataire (bleu)
  @HiveField(4)
  failed, // ✗  Échec d'envoi
}

/// Modèle principal d'un message
@HiveType(typeId: 0) // typeId: 0 = MessageModel dans Hive
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id; // Identifiant unique du message (UUID)

  @HiveField(1)
  final String senderId; // ID de l'expéditeur

  @HiveField(2)
  final String receiverId; // ID du destinataire (ou de la conversation)

  @HiveField(3)
  final String chatId; // ID de la conversation à laquelle appartient ce message

  @HiveField(4)
  final String content; // Contenu textuel du message

  @HiveField(5)
  final MessageType type; // Type du message (texte, image, etc.)

  @HiveField(6)
  final DateTime timestamp; // Date et heure d'envoi

  @HiveField(7)
  final MessageStatus status; // Statut de livraison

  @HiveField(8)
  final String? mediaUrl; // URL du média si type != text (nullable)

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.mediaUrl,
  });

  /// Crée un MessageModel depuis un JSON reçu de l'API Laravel
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      chatId: json['chat_id'].toString(),
      content: json['content'] ?? '',
      // Convertit la string "text" en enum MessageType.text
      type: MessageType.values.byName(json['type'] ?? 'text'),
      timestamp: DateTime.parse(json['created_at']),
      status: MessageStatus.delivered,
      mediaUrl: json['media_url'],
    );
  }

  /// Convertit le MessageModel en JSON pour l'envoyer à l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'chat_id': chatId,
      'content': content,
      'type': type.name, // Convertit l'enum en string "text", "image", etc.
      'created_at': timestamp.toIso8601String(),
      'media_url': mediaUrl,
    };
  }

  /// Crée une copie du message avec certains champs modifiés
  /// Utile pour mettre à jour le statut sans recréer tout l'objet
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? chatId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? mediaUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}
