/// ============================================================
/// message_cubit.dart
/// Cubit gérant les messages d'une conversation.
///
/// Ce Cubit est instancié pour CHAQUE écran de chat ouvert.
/// Il gère :
///   - Le chargement des messages locaux (Hive)
///   - L'envoi de nouveaux messages (Socket.io)
///   - La réception en temps réel (Socket.io callbacks)
///   - L'indicateur "en train d'écrire"
///
/// Note sur les enums :
///   - MessageLoadStatus : état de chargement de l'UI (ce fichier)
///   - MessageStatus     : statut de livraison d'un message (message_model.dart)
/// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/message_model.dart';
import '../../repositories/message_repository.dart';
import '../../services/socket_service.dart';

// ── État ──────────────────────────────────────────────────────

/// Phases de chargement de l'UI du chat
/// (distinct de MessageStatus dans message_model.dart qui gère la livraison)
enum MessageLoadStatus { initial, loading, loaded, error }

/// État complet de l'écran de chat
class MessageState extends Equatable {
  final MessageLoadStatus status; // Phase de chargement de l'UI
  final List<MessageModel> messages; // Liste des messages de la conversation
  final bool isTyping; // L'autre personne est-elle en train d'écrire ?
  final String errorMessage;

  const MessageState({
    required this.status,
    required this.messages,
    this.isTyping = false,
    this.errorMessage = '',
  });

  /// État initial : liste vide, rien en cours
  factory MessageState.initial() {
    return const MessageState(status: MessageLoadStatus.initial, messages: []);
  }

  /// Equatable compare ces champs pour éviter les rebuilds inutiles
  @override
  List<Object> get props => [status, messages, isTyping, errorMessage];

  /// Crée une copie avec certains champs modifiés (pattern immuable)
  MessageState copyWith({
    MessageLoadStatus? status,
    List<MessageModel>? messages,
    bool? isTyping,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────

class MessageCubit extends Cubit<MessageState> {
  final MessageRepository messageRepository;
  final String chatId; // ID de la conversation gérée par ce Cubit
  final String currentUserId; // ID de l'utilisateur connecté

  MessageCubit({
    required this.messageRepository,
    required this.chatId,
    required this.currentUserId,
  }) : super(MessageState.initial());

  // ── Initialisation ────────────────────────────────────────────

  /// Charge les messages locaux et configure les callbacks Socket.io.
  /// À appeler dans initState() de ChatScreen.
  void init() {
    // Charge les messages depuis Hive (instantané, pas de réseau)
    _loadLocalMessages();

    // Rejoint la "room" Socket.io pour cette conversation
    // Cela permet de recevoir uniquement les messages de ce chat
    SocketService.joinChat(chatId);

    // Callback : nouveau message reçu via Socket.io
    SocketService.onNewMessage = (MessageModel message) {
      if (message.chatId == chatId) {
        _onMessageReceived(message);
      }
    };

    // Callback : l'autre personne est en train d'écrire
    SocketService.onTyping = (incomingChatId) {
      if (incomingChatId == chatId) {
        emit(state.copyWith(isTyping: true));
      }
    };

    // Callback : l'autre personne a arrêté d'écrire
    SocketService.onStopTyping = (incomingChatId) {
      if (incomingChatId == chatId) {
        emit(state.copyWith(isTyping: false));
      }
    };
  }

  // ── Chargement des messages ───────────────────────────────────

  /// Charge les messages depuis le stockage local Hive.
  void _loadLocalMessages() {
    emit(state.copyWith(status: MessageLoadStatus.loading));

    final messages = messageRepository.getLocalMessages(chatId);

    emit(state.copyWith(status: MessageLoadStatus.loaded, messages: messages));
  }

  // ── Envoi de message ──────────────────────────────────────────

  /// Envoie un nouveau message texte.
  Future<void> sendTextMessage(String content, String receiverId) async {
    if (content.trim().isEmpty) return; // Ignore les messages vides

    // Crée l'objet MessageModel
    // L'ID temporaire est basé sur le timestamp (sera remplacé par l'ID serveur)
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      receiverId: receiverId,
      chatId: chatId,
      content: content.trim(),
      type: MessageType.text,
      timestamp: DateTime.now(),
      // MessageStatus.sending vient de message_model.dart
      status: MessageStatus.sending,
    );

    // Optimistic update : ajoute le message à l'UI immédiatement
    // sans attendre la confirmation du serveur → expérience fluide
    final updatedMessages = [...state.messages, message];
    emit(state.copyWith(messages: updatedMessages));

    // Envoie via le Repository (sauvegarde Hive + Socket.io)
    final sentMessage = await messageRepository.sendMessage(message);

    // Met à jour le statut du message dans la liste (sending → sent)
    final finalMessages = state.messages.map((m) {
      return m.id == message.id ? sentMessage : m;
    }).toList();

    emit(state.copyWith(messages: finalMessages));

    // Arrête l'indicateur "en train d'écrire" après l'envoi
    SocketService.emitStopTyping(chatId);
  }

  // ── Réception de message ──────────────────────────────────────

  /// Appelé quand un nouveau message arrive via Socket.io.
  Future<void> _onMessageReceived(MessageModel message) async {
    // Sauvegarde en local (Hive)
    await messageRepository.saveReceivedMessage(message);

    // Ajoute à la liste affichée
    final updatedMessages = [...state.messages, message];
    emit(state.copyWith(messages: updatedMessages));

    // Marque automatiquement comme lu (chat ouvert = message vu)
    await messageRepository.markAsRead(chatId, message.id);
  }

  // ── Indicateur de frappe ──────────────────────────────────────

  /// Notifie le serveur que l'utilisateur est en train d'écrire.
  /// À appeler dans le onChanged du TextField.
  void onTyping() {
    SocketService.emitTyping(chatId);
  }

  /// Notifie le serveur que l'utilisateur a arrêté d'écrire.
  void onStopTyping() {
    SocketService.emitStopTyping(chatId);
  }

  // ── Nettoyage ─────────────────────────────────────────────────

  @override
  Future<void> close() {
    // Quitte la room Socket.io quand l'écran de chat est fermé
    SocketService.leaveChat(chatId);
    return super.close();
  }
}
