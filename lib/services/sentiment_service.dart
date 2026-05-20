// sentiment_service.dart
// Service d'analyse de sentiment — Livrable de HANKPE Ulrich (Big Data & IA)
//
// Rôle : Analyser le sentiment d'un message AVANT son envoi.
// Retourne un score : positive | neutral | negative
//
// Deux modes de fonctionnement :
//   1. Mode LOCAL (actuel) : analyse basée sur des mots-clés en français
//      → Fonctionne sans connexion internet, sans clé API
//      → Utilisé tant qu'Ulrich n'a pas livré son endpoint Vertex AI
//
//   2. Mode VERTEX AI (quand Ulrich livre) :
//      → Décommenter la méthode _analyzeWithVertexAI()
//      → Remplir AppConstants.vertexAiUrl et AppConstants.vertexAiKey
//
// Intégration dans le projet :
//   - Appelé dans ChatScreen avant l'envoi d'un message
//   - Le score est affiché comme emoji sur la bulle (😊 😐 😠)
//   - Les métadonnées sont envoyées au pipeline Big Data d'Ulrich

import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

// Enum représentant les 3 scores de sentiment possibles
enum SentimentScore {
  positive, // 😊 Message positif
  neutral, // 😐 Message neutre
  negative, // 😠 Message négatif
}

class SentimentService {
  static final Dio _dio = Dio();

  // ── Méthode principale ────────────────────────────────────────

  /// Analyse le sentiment d'un texte.
  /// Utilise Vertex AI si configuré, sinon l'analyse locale.
  ///
  /// [text] : le message à analyser (en clair, AVANT chiffrement)
  /// Retourne : SentimentScore.positive | neutral | negative
  static Future<SentimentScore> analyze(String text) async {
    if (text.trim().isEmpty) return SentimentScore.neutral;

    // Si Ulrich a livré son endpoint Vertex AI → utiliser l'IA
    if (AppConstants.vertexAiUrl.isNotEmpty &&
        AppConstants.vertexAiKey.isNotEmpty) {
      return await _analyzeWithVertexAI(text);
    }

    // Sinon → analyse locale par mots-clés
    return _analyzeLocally(text);
  }

  // ── Mode 1 : Analyse locale par mots-clés ────────────────────

  /// Analyse le sentiment localement sans connexion internet.
  /// Basée sur des listes de mots positifs/négatifs en français.
  ///
  /// Algorithme :
  ///   1. Compte les mots positifs dans le texte
  ///   2. Compte les mots négatifs dans le texte
  ///   3. Si positifs > négatifs → positive
  ///   4. Si négatifs > positifs → negative
  ///   5. Sinon → neutral
  static SentimentScore _analyzeLocally(String text) {
    final lowerText = text.toLowerCase();

    // Mots positifs en français
    const positiveWords = [
      'super',
      'bien',
      'excellent',
      'parfait',
      'génial',
      'bravo',
      'merci',
      'top',
      'cool',
      'sympa',
      'beau',
      'belle',
      'magnifique',
      'formidable',
      'fantastique',
      'incroyable',
      'adorable',
      'heureux',
      'heureuse',
      'content',
      'contente',
      'joie',
      'amour',
      'aimer',
      'adorer',
      'félicitations',
      'oui',
      'ok',
      'accord',
      'avance',
      'réussi',
      'gagné',
      '😊',
      '😄',
      '🎉',
      '👍',
      '❤️',
      '🚀',
      '✅',
      '🙏',
      'bonne',
      'bon',
      'great',
      'good',
      'nice',
    ];

    // Mots négatifs en français
    const negativeWords = [
      'non',
      'pas',
      'jamais',
      'problème',
      'erreur',
      'bug',
      'mauvais',
      'mauvaise',
      'nul',
      'nulle',
      'horrible',
      'terrible',
      'catastrophe',
      'raté',
      'échoué',
      'impossible',
      'difficile',
      'triste',
      'dommage',
      'désolé',
      'désolée',
      'excuse',
      'pardon',
      'merde',
      'zut',
      'flûte',
      'énervé',
      'fâché',
      'colère',
      'frustré',
      'déçu',
      'déçue',
      '😠',
      '😢',
      '😞',
      '👎',
      '❌',
      '⚠️',
      'fail',
      'bad',
      'wrong',
      'no',
    ];

    // Compte les occurrences
    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in positiveWords) {
      if (lowerText.contains(word)) positiveCount++;
    }
    for (final word in negativeWords) {
      if (lowerText.contains(word)) negativeCount++;
    }

    // Détermine le score final
    if (positiveCount > negativeCount) return SentimentScore.positive;
    if (negativeCount > positiveCount) return SentimentScore.negative;
    return SentimentScore.neutral;
  }

  // ── Mode 2 : Vertex AI (quand Ulrich livre) ───────────────────

  /// Analyse le sentiment via l'API Vertex AI de Google Cloud.
  /// À activer quand Ulrich fournit son endpoint et sa clé API.
  ///
  /// Format de la requête (attendu par Vertex AI) :
  /// POST {vertexAiUrl}
  /// Headers: { "Authorization": "Bearer {vertexAiKey}" }
  /// Body: { "instances": [{ "content": "texte à analyser" }] }
  ///
  /// Format de la réponse :
  /// { "predictions": [{ "sentiment": "positive|neutral|negative", "score": 0.95 }] }
  static Future<SentimentScore> _analyzeWithVertexAI(String text) async {
    try {
      final response = await _dio.post(
        AppConstants.vertexAiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.vertexAiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          // Format Vertex AI Natural Language API
          'instances': [
            {'content': text},
          ],
        },
      );

      if (response.statusCode == 200) {
        // Extrait le score de la réponse Vertex AI
        final predictions = response.data['predictions'] as List;
        if (predictions.isNotEmpty) {
          final sentiment = predictions[0]['sentiment'] as String;
          return _parseScore(sentiment);
        }
      }
    } catch (e) {
      // Si Vertex AI échoue → fallback sur l'analyse locale
      print('[Sentiment] Vertex AI indisponible, fallback local: $e');
    }

    // Fallback : analyse locale si Vertex AI échoue
    return _analyzeLocally(text);
  }

  /// Convertit la string de sentiment en enum SentimentScore.
  static SentimentScore _parseScore(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return SentimentScore.positive;
      case 'negative':
        return SentimentScore.negative;
      default:
        return SentimentScore.neutral;
    }
  }

  // ── Utilitaires ───────────────────────────────────────────────

  /// Retourne l'emoji correspondant au score de sentiment.
  /// Affiché sur les bulles de message dans ChatScreen.
  static String getEmoji(SentimentScore score) {
    switch (score) {
      case SentimentScore.positive:
        return '😊';
      case SentimentScore.negative:
        return '😠';
      case SentimentScore.neutral:
        return '😐';
    }
  }

  /// Retourne la couleur correspondant au score.
  static int getColor(SentimentScore score) {
    switch (score) {
      case SentimentScore.positive:
        return 0xFF4CAF50; // Vert
      case SentimentScore.negative:
        return 0xFFCF6679; // Rouge
      case SentimentScore.neutral:
        return 0xFF9E9E9E; // Gris
    }
  }

  /// Retourne le label texte du score.
  static String getLabel(SentimentScore score) {
    switch (score) {
      case SentimentScore.positive:
        return 'Positif';
      case SentimentScore.negative:
        return 'Négatif';
      case SentimentScore.neutral:
        return 'Neutre';
    }
  }
}
