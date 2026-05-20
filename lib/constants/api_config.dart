// api_config.dart
// Configuration centralisée du client HTTP Dio.
// Intercepteur JWT automatique + gestion expiration token.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

// Navigateur global pour rediriger vers login sans contexte BuildContext
// Initialisé dans main.dart via router.routerDelegate
class ApiConfig {
  static Dio api() {
    final options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      validateStatus: (status) => status != null && status < 600,
    );

    final dio = Dio(options);

    // ── Intercepteur JWT ──────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        // Avant chaque requête : ajoute le token JWT automatiquement
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // Si erreur 401 (token expiré) : supprime le token local
        // L'app redirigera vers login au prochain checkAuthStatus()
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.tokenKey);
            await prefs.remove(AppConstants.userIdKey);
            debugPrint('[API] Token expiré — session supprimée');
          }
          return handler.next(e);
        },
      ),
    );

    // ── Logs (dev uniquement) ─────────────────────────────────────
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (log) => debugPrint('[API] $log'),
        ),
      );
    }

    return dio;
  }
}
