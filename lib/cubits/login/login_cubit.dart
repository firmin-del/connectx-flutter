/// ============================================================
/// login_cubit.dart
/// Cubit gérant la logique de connexion utilisateur.
///
/// Un Cubit est une classe qui :
///   1. Détient un état (LoginState)
///   2. Expose des méthodes que l'UI peut appeler
///   3. Émet de nouveaux états via emit() pour mettre à jour l'UI
///
/// L'UI (LoginScreen) écoute les changements d'état et réagit :
///   - loading  → affiche un indicateur de chargement
///   - loaded   → redirige vers l'écran principal
///   - error    → affiche un message d'erreur
/// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/api_repository/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  /// Le constructeur reçoit le Repository par injection de dépendance.
  /// Cela permet de tester le Cubit en passant un faux Repository (mock).
  LoginCubit({required this.authRepository})
    : super(LoginState.initial()); // État initial : formulaire vide

  // ── Connexion ─────────────────────────────────────────────────

  /// Tente de connecter l'utilisateur avec email et password.
  /// Met à jour l'état selon le résultat.
  Future<void> login(String email, String password) async {
    // Validation basique côté client avant d'appeler le serveur
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: "Veuillez remplir tous les champs.",
        ),
      );
      return;
    }

    // Émet l'état "loading" → l'UI affiche un spinner
    emit(state.copyWith(loginStatus: LoginStatus.loading));

    try {
      // Appelle le Repository qui appelle le Service qui appelle l'API
      final user = await authRepository.login(email.trim(), password);

      // Succès : émet l'état "loaded" avec les données de l'utilisateur
      emit(
        state.copyWith(
          loginStatus: LoginStatus.loaded,
          errorMessage: '',
          userName: user.name,
          userId: user.id,
        ),
      );
    } catch (e) {
      // Échec : émet l'état "error" avec le message d'erreur
      emit(
        state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ── Réinitialisation ──────────────────────────────────────────

  /// Remet le formulaire à son état initial.
  /// Utile quand l'utilisateur revient sur l'écran de login.
  void reset() {
    emit(LoginState.initial());
  }
}
