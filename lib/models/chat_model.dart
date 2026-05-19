// chat_model.dart
// Modèle représentant une conversation dans NovaX.
//
// Une conversation peut être :
//   - Privée : 2 participants (isGroup = false)
//   - Groupe : 3+ participants (isGroup = true, name obligatoire)
//
// Annoté @HiveType pour la persistance locale (cache des conversations).

import 'package:hive/hive.dart';
import 'user_model.dart';

part 'chat_model.g.dart';

/// Modèle d'une conversation
@HiveType(typeId: 3) // typeId: 3 = ChatModel (0,1,2 déjà pris par MessageModel)
class ChatModel extends HiveObject {
  @HiveField(0)
  final String id; // Identifiant unique de la conversation

  @HiveField(1)
  final List<String> participantIds; // IDs des participants (stockés en local)

  @HiveField(2)
  final String? name; // Nom du groupe (null pour conversation privée)

  @HiveField(3)
  final String? lastMessageContent; // Contenu du dernier message (aperçu)

  @HiveField(4)
  final DateTime lastActivity; // Date du dernier message (pour le tri)

  @HiveField(5)
  final int unreadCount; // Nombre de messages non lus (badge)

  @HiveField(6)
  final bool isGroup; // true = groupe, false = conversation privée

  @HiveField(7)
  final String? lastMessageSenderId; // ID de l'expéditeur du dernier message

  // Participants complets (non stockés dans Hive, chargés depuis l'API)
  // transient = non persisté, reconstruit à chaque chargement
  final List<UserModel> participants;

  ChatModel({
    required this.id,
    required this.participantIds,
    this.name,
    this.lastMessageContent,
    required this.lastActivity,
    this.unreadCount = 0,
    this.isGroup = false,
    this.lastMessageSenderId,
    this.participants = const [],
  });

  /// Crée un ChatModel depuis un JSON reçu de l'API Laravel
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Extrait les participants depuis le JSON
    final participantsList = (json['participants'] as List<dynamic>? ?? [])
        .map((p) => UserModel.fromJson(p as Map<String, dynamic>))
        .toList();

    // Extrait le dernier message si présent
    final lastMsg = json['last_message'] as Map<String, dynamic>?;

    return ChatModel(
      id: json['id'].toString(),
      participantIds: participantsList.map((p) => p.id).toList(),
      name: json['name'] as String?,
      lastMessageContent: lastMsg?['content'] as String?,
      lastActivity: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      unreadCount: json['unread_count'] as int? ?? 0,
      isGroup: json['is_group'] as bool? ?? false,
      lastMessageSenderId: lastMsg?['sender_id']?.toString(),
      participants: participantsList,
    );
  }

  /// Retourne le nom à afficher pour cette conversation.
  /// Pour un groupe : le nom du groupe.
  /// Pour une conversation privée : le nom de l'autre participant.
  String getDisplayName(String currentUserId) {
    if (isGroup && name != null) return name!;

    // Trouve l'autre participant (pas l'utilisateur courant)
    final other = participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => UserModel(id: '', name: 'Contact', email: ''),
    );
    return other.name;
  }

  /// Retourne l'aperçu du dernier message pour la liste des conversations.
  String get lastMessagePreview {
    if (lastMessageContent == null || lastMessageContent!.isEmpty) {
      return 'Nouvelle conversation';
    }
    // Tronque si trop long
    if (lastMessageContent!.length > 40) {
      return '${lastMessageContent!.substring(0, 40)}...';
    }
    return lastMessageContent!;
  }

  /// Crée une copie avec certains champs modifiés
  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    String? name,
    String? lastMessageContent,
    DateTime? lastActivity,
    int? unreadCount,
    bool? isGroup,
    String? lastMessageSenderId,
    List<UserModel>? participants,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      name: name ?? this.name,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      participants: participants ?? this.participants,
    );
  }
}
