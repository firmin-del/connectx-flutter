import 'package:clone_whatsapp_base_code/repositories/api_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.authRepository})
      : super(LoginState.initial());

  final AuthRepository authRepository;

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));

    try {
      // Simulation de connexion (on va la remplacer plus tard par un vrai appel API)
      await Future.delayed(const Duration(seconds: 1));

      if (email.isNotEmpty && password.isNotEmpty) {
        emit(state.copyWith(
          loginStatus: LoginStatus.loaded,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: "Email ou mot de passe incorrect",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        loginStatus: LoginStatus.error,
        errorMessage: "Erreur de connexion",
      ));
    }
  }
}