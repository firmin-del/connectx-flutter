/// ============================================================
/// message_repository.dart
/// Repository des messages : gère la synchronisation entre
/// le stockage local (Hive) et le serveur (Socket.io + API Laravel).
///
/// Stratégie "Offline First" :
///   1. Le message est d'abord sauvegardé localement (Hive)
///   2. Puis envoyé via Socket.io au serveur
///   3. Si l'envoi échoue, le message reste en local avec statut "failed"
///   4. L'UI affiche toujours les données locales (réactivité immédiate)
/// ============================================================

import '../models/message_model.dart';
import '../services/hive_service.dart';
import '../services/socket_service.dart';

class MessageRepository {
  // ── Envoi de message ──────────────────────────────────────────

  /// Envoie un message : sauvegarde local + émission Socket.io.
  /// Retourne le message avec son statut mis à jour.
  Future<MessageModel> sendMessage(MessageModel message) async {
    // Étape 1 : Sauvegarde immédiatement en local avec statut "sending"
    // L'UI peut afficher le message instantanément sans attendre le serveur
    await HiveService.saveMessage(message);

    try {
      // Étape 2 : Envoie via Socket.io au serveur Node.js
      SocketService.sendMessage(message);

      // Étape 3 : Met à jour le statut à "sent" (envoyé au serveur)
      final sentMessage = message.copyWith(status: MessageStatus.sent);
      await HiveService.saveMessage(sentMessage);

      return sentMessage;
    } catch (e) {
      // En cas d'échec, marque le message comme "failed"
      final failedMessage = message.copyWith(status: MessageStatus.failed);
      await HiveService.saveMessage(failedMessage);
      return failedMessage;
    }
  }

  // ── Récupération des messages ─────────────────────────────────

  /// Récupère les messages d'une conversation depuis le stockage local.
  /// Les messages sont triés du plus ancien au plus récent.
  List<MessageModel> getLocalMessages(String chatId) {
    return HiveService.getMessagesForChat(chatId);
  }

  /// Sauvegarde un message reçu via Socket.io en local.
  /// Appelé par le MessageCubit quand un nouveau message arrive.
  Future<void> saveReceivedMessage(MessageModel message) async {
    // Le message reçu est directement "delivered" (livré)
    final receivedMessage = message.copyWith(status: MessageStatus.delivered);
    await HiveService.saveMessage(receivedMessage);
  }

  // ── Statuts de lecture ────────────────────────────────────────

  /// Marque un message comme "lu" en local et notifie le serveur.
  Future<void> markAsRead(String chatId, String messageId) async {
    // Met à jour le statut local
    await HiveService.updateMessageStatus(messageId, MessageStatus.read);

    // Notifie le serveur via Socket.io pour que l'expéditeur voie les ✓✓ bleus
    SocketService.emitMessageRead(chatId, messageId);
  }

  // ── Suppression ───────────────────────────────────────────────

  /// Supprime tous les messages d'une conversation localement.
  Future<void> deleteConversation(String chatId) async {
    await HiveService.deleteMessagesForChat(chatId);
  }
}
