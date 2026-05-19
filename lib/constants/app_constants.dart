/// ============================================================
/// app_constants.dart
/// Toutes les constantes globales de l'application NovaX.
/// Centraliser ici évite les "magic strings" dispersés dans le code.
/// ============================================================

class AppConstants {
  // ── Identité de l'application ──────────────────────────────────
  static const String appName = "NovaX";
  static const String appVersion = "1.0.0";

  // ── URLs du serveur ────────────────────────────────────────────
  // 10.0.2.2 = adresse spéciale Android Emulator qui pointe vers localhost
  // À remplacer par l'IP réelle du serveur en production
  static const String baseUrl = "http://10.0.2.2:8000/api"; // Laravel API
  static const String socketUrl = "http://10.0.2.2:3000"; // Node.js Socket.io

  // ── Clés de stockage local (SharedPreferences) ─────────────────
  // Ces clés servent à sauvegarder/lire les données persistantes
  static const String tokenKey = "auth_token"; // Token JWT de connexion
  static const String userIdKey = "user_id"; // ID de l'utilisateur connecté
  static const String userNameKey = "user_name"; // Nom de l'utilisateur
  static const String userEmailKey = "user_email"; // Email de l'utilisateur

  // ── Noms des boîtes Hive (base de données locale) ──────────────
  // Chaque "box" Hive est comme une table dans une base de données
  static const String messagesBox = "messages_box"; // Stockage des messages
  static const String chatsBox = "chats_box"; // Stockage des conversations
  static const String usersBox = "users_box"; // Cache des profils utilisateurs

  // ── Durées ─────────────────────────────────────────────────────
  static const Duration splashDuration = Duration(
    seconds: 3,
  ); // Durée du splash screen
  static const Duration apiTimeout = Duration(
    seconds: 30,
  ); // Timeout des requêtes API

  // ── Messages d'erreur par défaut ───────────────────────────────
  static const String defaultErrorMessage =
      "Une erreur est survenue. Veuillez réessayer.";
  static const String networkErrorMessage =
      "Impossible de se connecter au serveur. Vérifiez votre connexion.";
  static const String authErrorMessage = "Email ou mot de passe incorrect.";
}
