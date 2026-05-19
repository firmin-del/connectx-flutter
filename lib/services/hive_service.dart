/// ============================================================
/// hive_service.dart
/// Service de gestion de la base de données locale Hive.
///
/// Hive est une base de données NoSQL légère et rapide.
/// Elle stocke les données sous forme de "boîtes" (boxes),
/// chaque boîte étant comme une table dans une base relationnelle.
///
/// Utilisation dans NovaX :
///   - Stocker les messages pour les lire hors-ligne
///   - Mettre en cache les conversations
/// ============================================================

import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart'; // Ajout Étape 03

class HiveService {
  // ── Initialisation ────────────────────────────────────────────

  /// Initialise Hive et enregistre tous les adaptateurs de types.
  /// Doit être appelé UNE SEULE FOIS au démarrage de l'app (dans main.dart).
  static Future<void> init() async {
    // Initialise Hive avec le dossier de l'application
    await Hive.initFlutter();

    // Enregistre les adaptateurs pour que Hive sache comment
    // sérialiser/désérialiser nos objets personnalisés
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter()); // typeId: 0
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MessageTypeAdapter()); // typeId: 1
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageStatusAdapter()); // typeId: 2
    }
    // Adaptateur ChatModel (Étape 03)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ChatModelAdapter()); // typeId: 3
    }

    // Ouvre les boîtes au démarrage pour un accès rapide ensuite
    await Hive.openBox<MessageModel>(AppConstants.messagesBox);
    await Hive.openBox<String>(AppConstants.chatsBox);
    await Hive.openBox<String>(AppConstants.usersBox);
  }

  // ── Accès aux boîtes ──────────────────────────────────────────

  /// Retourne la boîte des messages (déjà ouverte)
  static Box<MessageModel> get messagesBox =>
      Hive.box<MessageModel>(AppConstants.messagesBox);

  /// Retourne la boîte des conversations (déjà ouverte)
  static Box<String> get chatsBox => Hive.box<String>(AppConstants.chatsBox);

  // ── Opérations sur les messages ───────────────────────────────

  /// Sauvegarde un message localement.
  /// La clé est l'ID du message pour pouvoir le retrouver facilement.
  static Future<void> saveMessage(MessageModel message) async {
    await messagesBox.put(message.id, message);
  }

  /// Récupère tous les messages d'une conversation spécifique,
  /// triés du plus ancien au plus récent.
  static List<MessageModel> getMessagesForChat(String chatId) {
    // Filtre tous les messages pour ne garder que ceux du bon chat
    final messages = messagesBox.values
        .where((msg) => msg.chatId == chatId)
        .toList();

    // Trie par date d'envoi (ordre chronologique)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return messages;
  }

  /// Met à jour le statut d'un message (ex: "envoyé" → "lu")
  static Future<void> updateMessageStatus(
    String messageId,
    MessageStatus newStatus,
  ) async {
    final message = messagesBox.get(messageId);
    if (message != null) {
      // copyWith crée une nouvelle instance avec le statut mis à jour
      await messagesBox.put(messageId, message.copyWith(status: newStatus));
    }
  }

  /// Supprime tous les messages d'une conversation
  /// (utile si l'utilisateur supprime une conversation)
  static Future<void> deleteMessagesForChat(String chatId) async {
    // Trouve les clés des messages à supprimer
    final keysToDelete = messagesBox.keys.where((key) {
      final msg = messagesBox.get(key);
      return msg?.chatId == chatId;
    }).toList();

    // Supprime en lot
    await messagesBox.deleteAll(keysToDelete);
  }

  // ── Fermeture ─────────────────────────────────────────────────

  /// Ferme toutes les boîtes Hive proprement.
  /// À appeler quand l'application se ferme.
  static Future<void> closeAll() async {
    await Hive.close();
  }
}
