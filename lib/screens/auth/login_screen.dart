/// ============================================================
/// login_screen.dart
/// Écran de connexion utilisateur.
///
/// StatefulWidget car on a besoin de :
///   - TextEditingControllers pour lire les champs email/password
///   - setState pour afficher/masquer le mot de passe
///
/// Connecté au LoginCubit via BlocListener + BlocBuilder :
///   - BlocListener : réagit aux changements (redirection, SnackBar)
///   - BlocBuilder  : reconstruit le bouton selon l'état (loading/idle)
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/login/login_cubit.dart';
import '../../cubits/login/login_state.dart';
import '../../constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour lire le texte saisi dans chaque champ
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Contrôle la visibilité du mot de passe (icône œil)
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Libère les contrôleurs quand l'écran est détruit (évite les fuites mémoire)
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      // BlocListener écoute les changements d'état et réagit sans rebuild
      listener: (context, state) {
        if (state.loginStatus == LoginStatus.loaded) {
          // Connexion réussie → redirige vers la liste des conversations
          context.go('/home');
        } else if (state.loginStatus == LoginStatus.error) {
          // Erreur → affiche un message en bas de l'écran
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            // Évite l'overflow quand le clavier s'ouvre
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // ── Logo ──────────────────────────────────────────
                  Icon(
                    Icons.chat_bubble_rounded,
                    size: 90,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // ── Titre ─────────────────────────────────────────
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connecte-toi pour continuer",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  // ── Champ Email ───────────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    // Désactive l'autocorrection pour les emails
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "L'email est obligatoire";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Champ Mot de passe ────────────────────────────
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      // Bouton pour afficher/masquer le mot de passe
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le mot de passe est obligatoire";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Bouton Se connecter ───────────────────────────
                  // BlocBuilder reconstruit uniquement ce bouton selon l'état
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      final isLoading =
                          state.loginStatus == LoginStatus.loading;

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          // Désactive le bouton pendant le chargement
                          onPressed: isLoading ? null : _onLoginPressed,
                          child: isLoading
                              // Spinner pendant la requête API
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Se connecter",
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Lien vers l'inscription ───────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ? "),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Appelé quand l'utilisateur appuie sur "Se connecter".
  /// Valide le formulaire puis appelle le LoginCubit.
  void _onLoginPressed() {
    // Valide tous les champs (affiche les messages d'erreur si invalide)
    if (_formKey.currentState?.validate() ?? false) {
      // Tous les champs sont valides → appelle le Cubit
      context.read<LoginCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }
}
