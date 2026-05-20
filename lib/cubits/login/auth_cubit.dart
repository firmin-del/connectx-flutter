// auth_cubit.dart
// Gestion de la session globale + chargement du vrai profil depuis l'API.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../repositories/api_repository/auth_repository.dart';
import '../../services/auth_service.dart';
import '../../services/socket_service.dart';
import '../../constants/app_constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;

  const AuthState({required this.status, this.user});

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);
  factory AuthState.authenticated(UserModel user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthState.unknown());

  // ── Vérification de session au démarrage ──────────────────────

  /// Vérifie le token local et charge le vrai profil depuis GET /api/me.
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      try {
        // Charge le vrai profil depuis l'API (nom, email complets)
        final user = await authRepository.getMe();
        await _connectSocket();
        emit(AuthState.authenticated(user));
      } catch (_) {
        // Si l'API échoue, utilise les données sauvegardées localement
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(AppConstants.userIdKey) ?? '';
        final name = prefs.getString(AppConstants.userNameKey) ?? '';
        final email = prefs.getString(AppConstants.userEmailKey) ?? '';
        emit(
          AuthState.authenticated(
            UserModel(id: userId, name: name, email: email),
          ),
        );
      }
    } else {
      emit(AuthState.unauthenticated());
    }
  }

  // ── Mise à jour après login/register réussi ───────────────────

  /// Met à jour l'état global avec le vrai profil utilisateur.
  /// Appelé par LoginCubit après login ou register réussi.
  void setAuthenticated(UserModel user) {
    _connectSocket();
    emit(AuthState.authenticated(user));
  }

  // ── Mise à jour du profil ─────────────────────────────────────

  /// Met à jour le profil et rafraîchit l'état global.
  Future<void> updateProfile({String? name, String? phoneNumber}) async {
    final updatedUser = await authRepository.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
    );
    emit(AuthState.authenticated(updatedUser));
  }

  // ── Suppression du compte ─────────────────────────────────────

  Future<void> deleteAccount() async {
    SocketService.disconnect();
    await authRepository.deleteAccount();
    emit(AuthState.unauthenticated());
  }

  // ── Déconnexion ───────────────────────────────────────────────

  Future<void> logout() async {
    SocketService.disconnect();
    await authRepository.logout();
    emit(AuthState.unauthenticated());
  }

  // ── Méthodes privées ──────────────────────────────────────────

  Future<void> _connectSocket() async {
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      SocketService.connect(token);
    }
  }
}
