// chat_service.dart
// Service d'accès aux conversations via l'API Laravel.
//
// Ce service fait les appels HTTP pour :
//   - Récupérer la liste des conversations de l'utilisateur
//   - Créer une nouvelle conversation
//   - Récupérer les messages d'une conversation (historique)
//
// Flux : ChatCubit → ChatRepository → ChatService → Laravel API

import 'package:dio/dio.dart';
import '../constants/api_config.dart';
import '../constants/app_constants.dart';

class ChatService {
  // Instance Dio avec intercepteur JWT automatique
  static final Dio _api = ApiConfig.api();

  // ── Liste des conversations ───────────────────────────────────

  /// Récupère toutes les conversations de l'utilisateur connecté.
  /// Le token JWT dans le header identifie l'utilisateur côté Laravel.
  ///
  /// Retourne une liste de Map JSON représentant chaque conversation.
  static Future<List<Map<String, dynamic>>> getChats() async {
    try {
      // GET /api/chats → Laravel retourne les conversations de l'utilisateur
      final response = await _api.get('/chats');

      if (response.statusCode == 200) {
        // La réponse est une liste JSON : [{ id, participants, lastMessage, ... }]
        final List<dynamic> data = response.data as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          response.data['message'] ?? AppConstants.defaultErrorMessage,
        );
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Historique des messages ───────────────────────────────────

  /// Récupère les messages d'une conversation depuis le serveur.
  /// Utilisé pour synchroniser l'historique au premier chargement.
  ///
  /// [chatId]  : identifiant de la conversation
  /// [page]    : numéro de page pour la pagination (20 messages par page)
  static Future<List<Map<String, dynamic>>> getMessages(
    String chatId, {
    int page = 1,
  }) async {
    try {
      // GET /api/chats/{chatId}/messages?page=1
      final response = await _api.get(
        '/chats/$chatId/messages',
        queryParameters: {'page': page, 'per_page': 20},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          response.data['message'] ?? AppConstants.defaultErrorMessage,
        );
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Création de conversation ──────────────────────────────────

  /// Crée une nouvelle conversation avec un ou plusieurs participants.
  ///
  /// [participantIds] : liste des IDs des participants (sans l'utilisateur courant)
  /// [name]           : nom du groupe (null pour une conversation privée)
  static Future<Map<String, dynamic>> createChat({
    required List<String> participantIds,
    String? name,
  }) async {
    try {
      final response = await _api.post(
        '/chats',
        data: {
          'participant_ids': participantIds,
          if (name != null) 'name': name,
          'is_group': participantIds.length > 1,
        },
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          response.data['message'] ?? AppConstants.defaultErrorMessage,
        );
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Envoi de message via API ──────────────────────────────────

  /// Sauvegarde un message envoyé via l'API Laravel.
  /// Appelé en parallèle de l'envoi Socket.io.
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
    String? receiverId,
    String? mediaUrl,
  }) async {
    try {
      final response = await _api.post(
        '/chats/$chatId/messages',
        data: {
          'content': content,
          'type': type,
          if (receiverId != null) 'receiver_id': receiverId,
          if (mediaUrl != null) 'media_url': mediaUrl,
        },
      );
      if (response.statusCode == 201) {
        return response.data['message'] as Map<String, dynamic>;
      }
      throw Exception(
        response.data['message'] ?? AppConstants.defaultErrorMessage,
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ── Marquer comme lus ─────────────────────────────────────────

  /// Marque tous les messages d'un chat comme lus.
  static Future<void> markAsRead(String chatId) async {
    try {
      await _api.put('/chats/$chatId/messages/read');
    } catch (_) {
      // Silencieux — non bloquant
    }
  }

  static String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return "Le serveur met trop de temps à répondre.";
      case DioExceptionType.connectionError:
        return AppConstants.networkErrorMessage;
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ?? AppConstants.defaultErrorMessage;
      default:
        return AppConstants.defaultErrorMessage;
    }
  }
}
