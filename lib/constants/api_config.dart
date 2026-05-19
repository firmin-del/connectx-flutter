/// ============================================================
/// api_config.dart
/// Configuration centralisée du client HTTP Dio.
///
/// Dio est le client HTTP utilisé pour communiquer avec l'API Laravel.
/// Cette classe configure les options globales (URL, headers, timeout)
/// et ajoute des intercepteurs pour la gestion automatique du token JWT.
/// ============================================================

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

class ApiConfig {
  /// Crée et retourne une instance Dio configurée pour l'API NovaX.
  static Dio api() {
    // Options de base : URL, headers par défaut, timeouts
    final options = BaseOptions(
      baseUrl: AppConstants.baseUrl, // http://10.0.2.2:8000/api
      headers: {
        "Content-Type": "application/json", // On envoie du JSON
        "Accept": "application/json", // On attend du JSON en retour
      },
      connectTimeout: AppConstants.apiTimeout, // 30 secondes pour se connecter
      receiveTimeout:
          AppConstants.apiTimeout, // 30 secondes pour recevoir la réponse
      // On accepte tous les codes HTTP < 600 pour gérer les erreurs manuellement
      validateStatus: (status) => status != null && status < 600,
    );

    final dio = Dio(options);

    // ── Intercepteur JWT ──────────────────────────────────────────
    // Un intercepteur est un "middleware" qui s'exécute avant/après chaque requête.
    // Ici, on ajoute automatiquement le token JWT à chaque requête.
    dio.interceptors.add(
      InterceptorsWrapper(
        // onRequest : exécuté AVANT chaque requête
        onRequest: (options, handler) async {
          // Récupère le token JWT stocké localement
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);

          // Si un token existe, l'ajoute dans le header Authorization
          // Format Bearer : standard pour les API REST avec JWT
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Continue la requête normalement
          return handler.next(options);
        },

        // onError : exécuté si la requête échoue
        onError: (DioException e, handler) async {
          // Si le serveur répond 401 (Non autorisé), le token est expiré
          if (e.response?.statusCode == 401) {
            // Supprime le token invalide
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.tokenKey);
            // TODO: Rediriger vers l'écran de login (via GoRouter)
            print('[API] Token expiré, redirection vers login nécessaire');
          }
          return handler.next(e);
        },
      ),
    );

    // ── Intercepteur de logs (développement uniquement) ───────────
    // Affiche les requêtes et réponses dans la console pour déboguer
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true, // Affiche le corps des requêtes
        responseBody: true, // Affiche le corps des réponses
        logPrint: (log) =>
            print('[API] $log'), // Préfixe pour identifier les logs
      ),
    );

    return dio;
  }
}
