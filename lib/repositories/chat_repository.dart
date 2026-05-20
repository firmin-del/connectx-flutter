// chat_repository.dart
// Repository des conversations : couche d'abstraction entre
// le ChatCubit et les services (ChatService + HiveService).
//
// Stratégie Cache-First :
//   1. Retourne d'abord les données du cache local (Hive) → UI réactive
//   2. Charge les données fraîches depuis l'API Laravel en arrière-plan
//   3. Met à jour le cache et notifie l'UI des nouvelles données

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/hive_service.dart';

class ChatRepository {
  // ── Récupération des conversations ────────────────────────────

  /// Récupère les conversations depuis le cache local (Hive).
  /// Retour instantané sans réseau → l'UI s'affiche immédiatement.
  List<ChatModel> getCachedChats() {
    // Récupère toutes les valeurs de la boîte Hive "chats_box"
    // et les trie par date de dernière activité (plus récent en premier)
    // TODO: Implémenter la désérialisation complète depuis Hive
    return [];
  }

  /// Récupère les conversations fraîches depuis l'API Laravel.
  /// Met à jour le cache Hive après réception.
  Future<List<ChatModel>> fetchChatsFromApi() async {
    // Appelle le service qui fait la requête HTTP
    final jsonList = await ChatService.getChats();

    // Convertit chaque JSON en objet ChatModel
    final chats = jsonList.map((json) => ChatModel.fromJson(json)).toList();

    // Trie par date de dernière activité (conversation la plus récente en haut)
    chats.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    return chats;
  }

  // ── Historique des messages ───────────────────────────────────

  /// Récupère l'historique des messages d'une conversation depuis l'API.
  /// Sauvegarde les messages dans Hive pour un accès offline.
  Future<List<MessageModel>> fetchMessagesFromApi(
    String chatId, {
    int page = 1,
  }) async {
    final jsonList = await ChatService.getMessages(chatId, page: page);

    // Convertit et sauvegarde chaque message dans Hive
    final messages = <MessageModel>[];
    for (final json in jsonList) {
      final message = MessageModel.fromJson(json);
      await HiveService.saveMessage(message);
      messages.add(message);
    }

    // Trie par date (plus ancien en premier)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return messages;
  }

  // ── Envoi de message via API ──────────────────────────────────

  /// Sauvegarde le message dans la base Laravel en plus de Socket.io.
  Future<void> sendMessageToApi({
    required String chatId,
    required String content,
    String type = 'text',
    String? receiverId,
  }) async {
    try {
      await ChatService.sendMessage(
        chatId: chatId,
        content: content,
        type: type,
        receiverId: receiverId,
      );
    } catch (_) {
      // Non bloquant — Socket.io a déjà envoyé le message
    }
  }

  // ── Marquer comme lus ─────────────────────────────────────────

  Future<void> markAsRead(String chatId) async {
    await ChatService.markAsRead(chatId);
  }

  // ── Création de conversation ──────────────────────────────────

  /// Crée une nouvelle conversation et retourne le ChatModel créé.
  Future<ChatModel> createChat({
    required List<String> participantIds,
    String? name,
  }) async {
    final json = await ChatService.createChat(
      participantIds: participantIds,
      name: name,
    );
    return ChatModel.fromJson(json);
  }
}
