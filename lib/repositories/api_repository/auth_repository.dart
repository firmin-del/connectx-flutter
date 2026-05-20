/// ============================================================
/// auth_repository.dart
/// Repository d'authentification : couche d'abstraction entre
/// le Cubit et le Service.
///
/// Pourquoi ce pattern Repository ?
///   - Le Cubit ne connaît pas les détails d'implémentation (HTTP, Hive...)
///   - Si on change de backend, on modifie seulement le Repository
///   - Facilite les tests unitaires (on peut mocker le Repository)
///
/// Flux : LoginCubit → AuthRepository → AuthService → Laravel API
/// ============================================================

import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AuthRepository {
  // ── Connexion ─────────────────────────────────────────────────

  /// Connecte l'utilisateur et retourne son profil.
  /// Lance une exception si les identifiants sont incorrects.
  Future<UserModel> login(String email, String password) async {
    // Délègue l'appel HTTP au AuthService
    final data = await AuthService.login(email, password);

    // Convertit les données JSON en objet UserModel typé
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ── Inscription ───────────────────────────────────────────────

  /// Crée un nouveau compte et retourne le profil créé.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final data = await AuthService.register(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  // ── Déconnexion ───────────────────────────────────────────────

  /// Déconnecte l'utilisateur (invalide le token côté serveur + local).
  Future<void> logout() async {
    await AuthService.logout();
  }

  // ── Profil ────────────────────────────────────────────────────

  Future<UserModel> getMe() async {
    final data = await AuthService.getMe();
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({String? name, String? phoneNumber}) async {
    final data = await AuthService.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
    );
    return UserModel.fromJson(data);
  }

  Future<void> deleteAccount() async {
    await AuthService.deleteAccount();
  }

  // ── Vérification de session ───────────────────────────────────

  /// Vérifie si l'utilisateur est déjà connecté (token valide en local).
  /// Utilisé par le SplashScreen pour décider où naviguer.
  Future<bool> isLoggedIn() async {
    return await AuthService.isLoggedIn();
  }

  /// Récupère l'ID de l'utilisateur actuellement connecté.
  Future<String?> getCurrentUserId() async {
    return await AuthService.getCurrentUserId();
  }
}
