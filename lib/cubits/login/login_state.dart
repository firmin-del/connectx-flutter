/// ============================================================
/// login_state.dart
/// État du processus de connexion.
///
/// Equatable permet à BLoC de comparer deux états pour savoir
/// si l'UI doit se reconstruire. Sans Equatable, deux objets
/// identiques seraient considérés différents (comparaison par référence).
/// ============================================================

import 'package:equatable/equatable.dart';

/// Les différentes phases du processus de login
enum LoginStatus {
  initial, // Formulaire vide, rien n'a encore été fait
  loading, // Requête en cours → afficher un spinner
  loaded, // Connexion réussie → rediriger vers home
  error, // Connexion échouée → afficher le message d'erreur
}

class LoginState extends Equatable {
  final LoginStatus loginStatus;
  final String errorMessage;
  final String userName; // Nom de l'utilisateur connecté (après succès)
  final String userId; // ID de l'utilisateur connecté (après succès)

  const LoginState({
    required this.loginStatus,
    required this.errorMessage,
    this.userName = '',
    this.userId = '',
  });

  /// État initial : formulaire vide, aucune erreur
  factory LoginState.initial() {
    return const LoginState(
      loginStatus: LoginStatus.initial,
      errorMessage: '',
      userName: '',
      userId: '',
    );
  }

  /// Equatable utilise cette liste pour comparer deux états.
  /// Si tous les champs sont identiques → pas de rebuild de l'UI.
  @override
  List<Object> get props => [loginStatus, errorMessage, userName, userId];

  /// Crée une copie de l'état avec certains champs modifiés.
  /// Pattern immuable : on ne modifie jamais l'état existant,
  /// on en crée toujours un nouveau.
  LoginState copyWith({
    LoginStatus? loginStatus,
    String? errorMessage,
    String? userName,
    String? userId,
  }) {
    return LoginState(
      loginStatus: loginStatus ?? this.loginStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
    );
  }
}
