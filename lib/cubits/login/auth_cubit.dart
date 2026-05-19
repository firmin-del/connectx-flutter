/// ============================================================
/// auth_cubit.dart
/// Cubit gérant l'état global d'authentification de l'application.
///
/// Différence avec LoginCubit :
///   - LoginCubit : gère UNIQUEMENT le formulaire de login
///   - AuthCubit  : gère l'état de session GLOBAL (connecté/déconnecté)
///                  et est disponible dans toute l'application
///
/// Utilisé par :
///   - SplashScreen : pour savoir si l'utilisateur est déjà connecté
///   - AppBar : pour afficher le nom de l'utilisateur
///   - Bouton déconnexion : pour effacer la session
/// ============================================================

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../repositories/api_repository/auth_repository.dart';
import '../../services/auth_service.dart'; // Ajout Étape 03
import '../../services/socket_service.dart';

// ── État ──────────────────────────────────────────────────────

/// Les différents états de session possibles
enum AuthStatus {
  unknown, // État initial : on ne sait pas encore si connecté
  authenticated, // Utilisateur connecté avec un token valide
  unauthenticated, // Utilisateur non connecté (ou déconnecté)
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user; // L'utilisateur connecté (null si non connecté)

  const AuthState({required this.status, this.user});

  /// État initial : on ne sait pas encore (vérification en cours)
  factory AuthState.unknown() {
    return const AuthState(status: AuthStatus.unknown);
  }

  /// Utilisateur authentifié
  factory AuthState.authenticated(UserModel user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// Utilisateur non authentifié
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  @override
  List<Object?> get props => [status, user];
}

// ── Cubit ─────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthState.unknown());

  // ── Vérification de session au démarrage ──────────────────────

  /// Vérifie si un token valide existe en local.
  /// Appelé par le SplashScreen pour décider où naviguer.
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      // Token trouvé : l'utilisateur est considéré connecté
      // TODO: Optionnel - vérifier la validité du token auprès du serveur
      final userId = await authRepository.getCurrentUserId();
      emit(
        AuthState.authenticated(
          UserModel(
            id: userId ?? '',
            name: '', // Sera chargé depuis le profil
            email: '',
          ),
        ),
      );
    } else {
      // Pas de token : l'utilisateur doit se connecter
      emit(AuthState.unauthenticated());
    }
  }

  // ── Mise à jour après login réussi ────────────────────────────

  /// Met à jour l'état global après une connexion réussie.
  /// Appelé par le LoginCubit après un login réussi.
  void setAuthenticated(UserModel user) {
    // Connecte le Socket.io maintenant qu'on a le token
    // Le token est récupéré automatiquement par AuthService.getToken()
    _connectSocket();
    emit(AuthState.authenticated(user));
  }

  // ── Déconnexion ───────────────────────────────────────────────

  /// Déconnecte l'utilisateur : supprime le token + déconnecte le socket.
  Future<void> logout() async {
    // Déconnecte le Socket.io proprement
    SocketService.disconnect();

    // Supprime le token et les données locales
    await authRepository.logout();

    // Met à jour l'état global → l'UI redirige vers login
    emit(AuthState.unauthenticated());
  }

  // ── Méthodes privées ──────────────────────────────────────────

  /// Établit la connexion Socket.io après authentification.
  Future<void> _connectSocket() async {
    // Récupère le token JWT sauvegardé localement
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      // Connecte le socket avec le token pour que Node.js identifie l'utilisateur
      SocketService.connect(token);
    }
  }
}
