/// ============================================================
/// socket_service.dart
/// Service de connexion WebSocket vers le serveur Node.js/Socket.io.
///
/// Socket.io permet la communication BIDIRECTIONNELLE en temps réel :
///   - Le serveur peut envoyer des données au client sans que le client
///     n'ait à faire une requête (contrairement à HTTP classique).
///
/// Flux d'un message dans NovaX :
///   1. Utilisateur A tape un message → Flutter appelle sendMessage()
///   2. Le message est émis via Socket.io vers Node.js
///   3. Node.js le relaie instantanément à l'Utilisateur B
///   4. Flutter de B reçoit l'événement 'new_message' et met à jour l'UI
/// ============================================================

import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';
import '../models/message_model.dart';

class SocketService {
  // Instance unique du socket (singleton pattern)
  static IO.Socket? _socket;

  // Callbacks : fonctions appelées quand un événement arrive
  // Elles sont définies par le Cubit qui utilise ce service
  static Function(MessageModel)? onNewMessage; // Nouveau message reçu
  static Function(String)? onUserOnline; // Un contact vient de se connecter
  static Function(String)? onUserOffline; // Un contact vient de se déconnecter
  static Function(String)? onTyping; // Un contact est en train d'écrire
  static Function(String)? onStopTyping; // Un contact a arrêté d'écrire
  static Function(String, String)?
  onMessageRead; // Un message a été lu (chatId, messageId)

  // ── Connexion ─────────────────────────────────────────────────

  /// Établit la connexion WebSocket avec le serveur Node.js.
  /// [token] : le token JWT pour authentifier l'utilisateur côté serveur.
  static void connect(String token) {
    // Si déjà connecté, on ne recrée pas la connexion
    if (_socket != null && _socket!.connected) return;

    // Configuration de la connexion Socket.io
    _socket = IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports([
            'websocket',
          ]) // Utilise WebSocket (plus rapide que polling)
          .disableAutoConnect() // On contrôle manuellement la connexion
          .setAuth({
            'token': token,
          }) // Envoie le token JWT pour l'authentification
          .build(),
    );

    // Lance la connexion
    _socket!.connect();

    // ── Événements de connexion ──────────────────────────────────

    // Déclenché quand la connexion est établie avec succès
    _socket!.onConnect((_) {
      print('[Socket] ✅ Connecté au serveur NovaX (${AppConstants.socketUrl})');
    });

    // Déclenché si la connexion échoue ou est perdue
    _socket!.onDisconnect((_) {
      print('[Socket] ❌ Déconnecté du serveur');
    });

    // Déclenché en cas d'erreur de connexion
    _socket!.onConnectError((error) {
      print('[Socket] ⚠️ Erreur de connexion : $error');
    });

    // ── Écoute des événements métier ────────────────────────────

    // Événement : nouveau message reçu
    // Le serveur Node.js émet 'new_message' quand quelqu'un nous envoie un message
    _socket!.on('new_message', (data) {
      try {
        // Convertit les données JSON en objet MessageModel
        final message = MessageModel.fromJson(data as Map<String, dynamic>);
        // Appelle le callback si défini (le Cubit mettra à jour l'UI)
        onNewMessage?.call(message);
      } catch (e) {
        print('[Socket] Erreur parsing message : $e');
      }
    });

    // Événement : un contact vient de se connecter
    _socket!.on('user_online', (userId) {
      onUserOnline?.call(userId.toString());
    });

    // Événement : un contact vient de se déconnecter
    _socket!.on('user_offline', (userId) {
      onUserOffline?.call(userId.toString());
    });

    // Événement : un contact est en train d'écrire
    _socket!.on('typing', (chatId) {
      onTyping?.call(chatId.toString());
    });

    // Événement : un contact a arrêté d'écrire
    _socket!.on('stop_typing', (chatId) {
      onStopTyping?.call(chatId.toString());
    });

    // Événement : confirmation qu'un message a été lu
    _socket!.on('message_read', (data) {
      final chatId = data['chat_id'].toString();
      final messageId = data['message_id'].toString();
      onMessageRead?.call(chatId, messageId);
    });
  }

  // ── Émission d'événements ─────────────────────────────────────

  /// Envoie un message via Socket.io au serveur Node.js.
  /// Le serveur le relaie ensuite au destinataire.
  static void sendMessage(MessageModel message) {
    if (_socket == null || !_socket!.connected) {
      print('[Socket] ⚠️ Impossible d\'envoyer : non connecté');
      return;
    }
    // Émet l'événement 'send_message' avec les données du message en JSON
    _socket!.emit('send_message', message.toJson());
  }

  /// Notifie le serveur que l'utilisateur est en train d'écrire.
  /// Le serveur le relaie à l'autre participant du chat.
  static void emitTyping(String chatId) {
    _socket?.emit('typing', {'chat_id': chatId});
  }

  /// Notifie le serveur que l'utilisateur a arrêté d'écrire.
  static void emitStopTyping(String chatId) {
    _socket?.emit('stop_typing', {'chat_id': chatId});
  }

  /// Notifie le serveur qu'un message a été lu.
  static void emitMessageRead(String chatId, String messageId) {
    _socket?.emit('message_read', {'chat_id': chatId, 'message_id': messageId});
  }

  /// Rejoint une "room" Socket.io pour une conversation.
  /// Les rooms permettent d'envoyer des messages uniquement aux
  /// participants d'une conversation spécifique.
  static void joinChat(String chatId) {
    _socket?.emit('join_chat', {'chat_id': chatId});
  }

  /// Quitte une room Socket.io (quand on ferme l'écran de chat).
  static void leaveChat(String chatId) {
    _socket?.emit('leave_chat', {'chat_id': chatId});
  }

  // ── Déconnexion ───────────────────────────────────────────────

  /// Déconnecte proprement le socket.
  /// À appeler lors de la déconnexion de l'utilisateur.
  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    print('[Socket] 🔌 Socket déconnecté et nettoyé');
  }

  // ── État ──────────────────────────────────────────────────────

  /// Retourne true si le socket est actuellement connecté
  static bool get isConnected => _socket?.connected ?? false;
}
