// chat_cubit.dart
// Cubit gérant la liste des conversations (écran Home).
//
// Ce Cubit est global (disponible dans toute l'app via BlocProvider).
// Il gère :
//   - Le chargement des conversations depuis l'API Laravel
//   - La mise à jour en temps réel quand un nouveau message arrive
//   - Le tri des conversations (plus récente en haut)
//   - Le badge de messages non lus
//
// Stratégie d'affichage :
//   1. Affiche d'abord les données mockées (si API pas encore prête)
//   2. Charge les vraies données depuis l'API en arrière-plan
//   3. Met à jour l'UI quand les données arrivent

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/chat_model.dart';
import '../../repositories/chat_repository.dart';

// ── État ──────────────────────────────────────────────────────

/// Phases de chargement de la liste des conversations
enum ChatLoadStatus { initial, loading, loaded, error }

/// État complet de la liste des conversations
class ChatState extends Equatable {
  final ChatLoadStatus status;
  final List<ChatModel> chats; // Liste des conversations triées
  final String errorMessage;

  const ChatState({
    required this.status,
    required this.chats,
    this.errorMessage = '',
  });

  /// État initial : liste vide
  factory ChatState.initial() {
    return const ChatState(status: ChatLoadStatus.initial, chats: []);
  }

  @override
  List<Object> get props => [status, chats, errorMessage];

  ChatState copyWith({
    ChatLoadStatus? status,
    List<ChatModel>? chats,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository chatRepository;
  final String currentUserId; // ID de l'utilisateur connecté

  ChatCubit({required this.chatRepository, required this.currentUserId})
    : super(ChatState.initial());

  // ── Chargement des conversations ──────────────────────────────

  /// Charge les conversations depuis l'API Laravel.
  /// Affiche des données mockées si l'API n'est pas encore disponible.
  Future<void> loadChats() async {
    emit(state.copyWith(status: ChatLoadStatus.loading));

    try {
      // Tente de charger depuis l'API Laravel
      final chats = await chatRepository.fetchChatsFromApi();
      emit(state.copyWith(status: ChatLoadStatus.loaded, chats: chats));
    } catch (e) {
      // Si l'API n'est pas disponible, affiche des données mockées
      // pour que l'UI reste fonctionnelle pendant le développement
      final mockChats = _generateMockChats();
      emit(
        state.copyWith(
          status: ChatLoadStatus.loaded,
          chats: mockChats,
          errorMessage: 'Mode démo — serveur non disponible',
        ),
      );
    }
  }

  // ── Mise à jour en temps réel ─────────────────────────────────

  /// Met à jour une conversation quand un nouveau message arrive via Socket.io.
  /// Appelé par le MessageCubit quand un message est reçu.
  void updateChatWithNewMessage({
    required String chatId,
    required String lastMessageContent,
    required String senderId,
  }) {
    // Trouve la conversation dans la liste
    final updatedChats = state.chats.map((chat) {
      if (chat.id == chatId) {
        // Met à jour le dernier message et incrémente le badge non-lu
        // (sauf si c'est notre propre message)
        final isOwnMessage = senderId == currentUserId;
        return chat.copyWith(
          lastMessageContent: lastMessageContent,
          lastActivity: DateTime.now(),
          unreadCount: isOwnMessage ? chat.unreadCount : chat.unreadCount + 1,
        );
      }
      return chat;
    }).toList();

    // Retrie par date (la conversation avec le nouveau message remonte en haut)
    updatedChats.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    emit(state.copyWith(chats: updatedChats));
  }

  /// Remet à zéro le badge non-lu d'une conversation (quand on l'ouvre).
  void markChatAsRead(String chatId) {
    final updatedChats = state.chats.map((chat) {
      if (chat.id == chatId) {
        return chat.copyWith(unreadCount: 0);
      }
      return chat;
    }).toList();

    emit(state.copyWith(chats: updatedChats));
  }

  // ── Données mockées ───────────────────────────────────────────

  /// Génère des conversations fictives pour le développement.
  /// Utilisé quand le serveur Laravel n'est pas encore disponible.
  List<ChatModel> _generateMockChats() {
    return List.generate(8, (index) {
      return ChatModel(
        id: '${index + 1}',
        participantIds: ['user_${index + 1}'],
        name: null,
        lastMessageContent: _mockMessages[index % _mockMessages.length],
        lastActivity: DateTime.now().subtract(Duration(minutes: index * 15)),
        unreadCount: index % 3 == 0 ? 2 : 0, // Quelques badges non-lus
        isGroup: false,
        participants: [],
      );
    });
  }

  // Messages mockés pour l'aperçu
  static const List<String> _mockMessages = [
    "Salut, ça va ?",
    "On se retrouve à quelle heure ?",
    "J'ai envoyé le fichier 📎",
    "Merci pour tout !",
    "Tu as vu le dernier match ?",
    "Appelle-moi quand tu peux",
    "C'est bon pour moi 👍",
    "À demain !",
  ];
}
