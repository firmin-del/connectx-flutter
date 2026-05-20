// analytics_service.dart
// Service de pipeline Big Data — Livrable de HANKPE Ulrich (Big Data & IA)
//
// Rôle : Extraire les métadonnées anonymisées des messages et les envoyer
// vers Google Sheets pour alimenter le dashboard Looker Studio d'Ulrich.
//
// Données collectées (anonymisées — pas de contenu des messages) :
//   - Heure d'envoi
//   - Longueur du message (nombre de caractères)
//   - Score de sentiment (positive/neutral/negative)
//   - ID de la conversation (anonymisé)
//
// ⚠️ IMPORTANT : On n'envoie JAMAIS le contenu du message
// (respect du chiffrement E2EE et de la vie privée)
//
// Flux :
//   ChatScreen → SentimentService.analyze() → AnalyticsService.track()
//   → Google Sheets API d'Ulrich → Looker Studio Dashboard

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'sentiment_service.dart';

class AnalyticsService {
  static final Dio _dio = Dio();

  // ── Tracking d'un message envoyé ─────────────────────────────

  /// Envoie les métadonnées anonymisées d'un message vers Google Sheets.
  ///
  /// [messageLength] : longueur du message en caractères
  /// [sentiment]     : score de sentiment analysé par SentimentService
  /// [chatId]        : ID de la conversation (anonymisé avec hash)
  /// [timestamp]     : heure d'envoi
  ///
  /// Cette méthode est non-bloquante (fire and forget) :
  /// elle n'attend pas la réponse pour ne pas ralentir l'envoi du message.
  static Future<void> trackMessage({
    required int messageLength,
    required SentimentScore sentiment,
    required String chatId,
    required DateTime timestamp,
  }) async {
    // Si Ulrich n'a pas encore livré son URL → on log localement
    if (AppConstants.googleSheetsUrl.isEmpty) {
      _logLocally(
        messageLength: messageLength,
        sentiment: sentiment,
        chatId: chatId,
        timestamp: timestamp,
      );
      return;
    }

    try {
      // Envoie vers Google Sheets API d'Ulrich
      // Format attendu par le pipeline Big Data
      await _dio.post(
        AppConstants.googleSheetsUrl,
        data: {
          'timestamp': timestamp.toIso8601String(),
          'message_length': messageLength,
          'sentiment': SentimentService.getLabel(sentiment),
          'sentiment_score': sentiment.name,
          // Hash de l'ID pour anonymiser (pas l'ID réel)
          'chat_id_hash': chatId.hashCode.abs().toString(),
          'hour_of_day': timestamp.hour,
          'day_of_week': timestamp.weekday,
        },
      );
    } catch (e) {
      // Silencieux : le tracking ne doit jamais bloquer l'app
      _logLocally(
        messageLength: messageLength,
        sentiment: sentiment,
        chatId: chatId,
        timestamp: timestamp,
      );
    }
  }

  // ── Log local (quand Google Sheets n'est pas configuré) ───────

  /// Affiche les métadonnées dans la console pour le développement.
  /// Simule ce que le pipeline Big Data d'Ulrich recevrait.
  static void _logLocally({
    required int messageLength,
    required SentimentScore sentiment,
    required String chatId,
    required DateTime timestamp,
  }) {
    print(
      '[Analytics] Message tracké — '
      'Heure: ${timestamp.hour}h${timestamp.minute.toString().padLeft(2, '0')} | '
      'Longueur: $messageLength chars | '
      'Sentiment: ${SentimentService.getLabel(sentiment)} ${SentimentService.getEmoji(sentiment)} | '
      'Chat: ${chatId.hashCode.abs()}',
    );
  }

  // ── Statistiques de session ───────────────────────────────────

  /// Calcule les statistiques de sentiment pour une session.
  /// Utilisé pour afficher un résumé dans le profil ou le dashboard.
  ///
  /// [scores] : liste des scores de sentiment de la session
  /// Retourne : { 'positive': 5, 'neutral': 3, 'negative': 1, 'mood': 'positive' }
  static Map<String, dynamic> calculateSessionStats(
    List<SentimentScore> scores,
  ) {
    if (scores.isEmpty) {
      return {'positive': 0, 'neutral': 0, 'negative': 0, 'mood': 'neutral'};
    }

    // Compte chaque type de sentiment
    final positive = scores.where((s) => s == SentimentScore.positive).length;
    final neutral = scores.where((s) => s == SentimentScore.neutral).length;
    final negative = scores.where((s) => s == SentimentScore.negative).length;

    // Détermine le mood général de la session
    String mood = 'neutral';
    if (positive > negative && positive > neutral) mood = 'positive';
    if (negative > positive && negative > neutral) mood = 'negative';

    return {
      'positive': positive,
      'neutral': neutral,
      'negative': negative,
      'mood': mood,
      'total': scores.length,
    };
  }
}
