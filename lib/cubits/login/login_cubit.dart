// login_cubit.dart
// Cubit gérant la logique de connexion ET d'inscription.

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/api_repository/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(LoginState.initial());

  // ── Connexion ─────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: "Veuillez remplir tous les champs.",
        ),
      );
      return;
    }

    emit(state.copyWith(loginStatus: LoginStatus.loading));

    try {
      final user = await authRepository.login(email.trim(), password);
      emit(
        state.copyWith(
          loginStatus: LoginStatus.loaded,
          errorMessage: '',
          userName: user.name,
          userId: user.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ── Inscription ───────────────────────────────────────────────

  /// Crée un nouveau compte utilisateur.
  /// Appelé par RegisterScreen avec les données du formulaire.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: "Veuillez remplir tous les champs obligatoires.",
        ),
      );
      return;
    }

    emit(state.copyWith(loginStatus: LoginStatus.loading));

    try {
      final user = await authRepository.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phoneNumber: phoneNumber,
      );
      emit(
        state.copyWith(
          loginStatus: LoginStatus.loaded,
          errorMessage: '',
          userName: user.name,
          userId: user.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ── Réinitialisation ──────────────────────────────────────────

  void reset() {
    emit(LoginState.initial());
  }
}
