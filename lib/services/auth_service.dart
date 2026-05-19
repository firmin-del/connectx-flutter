/// ============================================================
/// auth_service.dart
/// Service d'authentification : communique avec l'API Laravel.
///
/// Ce service est la couche la plus basse de l'auth.
/// Il fait les appels HTTP bruts et retourne les données JSON.
/// Le Repository au-dessus lui donne du sens métier.
///
/// Flux complet :
///   LoginScreen → LoginCubit → AuthRepository → AuthService → Laravel API
/// ============================================================

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';
import '../constants/app_constants.dart';

class AuthService {
  // Instance Dio configurée (baseUrl, headers, timeout)
  static final Dio _api = ApiConfig.api();

  // ── Connexion ─────────────────────────────────────────────────

  /// Envoie les identifiants à l'API Laravel et récupère le token JWT.
  /// Retourne un Map avec les données de l'utilisateur et le token.
  /// Lance une exception si les identifiants sont incorrects.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      // POST /api/login avec email et password
      final response = await _api.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // Vérifie que la réponse est un succès (code 200)
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Sauvegarde le token JWT localement pour les prochaines requêtes
        await _saveToken(data['token'], data['user']);

        return data; // Retourne { token, user: { id, name, email, ... } }
      } else {
        // Le serveur a répondu mais avec une erreur (401, 422, etc.)
        throw Exception(
          response.data['message'] ?? AppConstants.authErrorMessage,
        );
      }
    } on DioException catch (e) {
      // Erreur réseau (pas de connexion, timeout, etc.)
      throw Exception(_handleDioError(e));
    }
  }

  // ── Inscription ───────────────────────────────────────────────

  /// Crée un nouveau compte utilisateur via l'API Laravel.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final response = await _api.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel exige la confirmation
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 201) {
        // 201 = Created : compte créé avec succès
        final data = response.data as Map<String, dynamic>;
        await _saveToken(data['token'], data['user']);
        return data;
      } else {
        throw Exception(
          response.data['message'] ?? AppConstants.defaultErrorMessage,
        );
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────

  /// Invalide le token côté serveur et supprime les données locales.
  static Future<void> logout() async {
    try {
      // Informe le serveur Laravel d'invalider le token
      await _api.post('/logout');
    } catch (_) {
      // Même si le serveur échoue, on nettoie localement
    } finally {
      // Supprime toutes les données de session locales
      await _clearLocalData();
    }
  }

  // ── Vérification de session ───────────────────────────────────

  /// Vérifie si un token valide existe localement.
  /// Utilisé au démarrage (SplashScreen) pour savoir si l'utilisateur
  /// est déjà connecté ou doit se reconnecter.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Récupère le token JWT stocké localement.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Récupère l'ID de l'utilisateur connecté.
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey);
  }

  // ── Méthodes privées ──────────────────────────────────────────

  /// Sauvegarde le token JWT et les infos utilisateur en local.
  /// Appelé après login et register réussis.
  static Future<void> _saveToken(
    String token,
    Map<String, dynamic> user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userIdKey, user['id'].toString());
    await prefs.setString(AppConstants.userNameKey, user['name'] ?? '');
    await prefs.setString(AppConstants.userEmailKey, user['email'] ?? '');
  }

  /// Supprime toutes les données de session locales.
  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.userEmailKey);
  }

  /// Traduit les erreurs Dio en messages lisibles pour l'utilisateur.
  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return "Le serveur met trop de temps à répondre. Réessayez.";
      case DioExceptionType.connectionError:
        return AppConstants.networkErrorMessage;
      case DioExceptionType.badResponse:
        // Le serveur a répondu avec un code d'erreur
        return e.response?.data['message'] ?? AppConstants.defaultErrorMessage;
      default:
        return AppConstants.defaultErrorMessage;
    }
  }
}
