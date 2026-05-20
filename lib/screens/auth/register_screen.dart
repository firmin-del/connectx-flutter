/// ============================================================
/// register_screen.dart
/// Écran d'inscription : permet à un nouvel utilisateur de créer
/// son compte NovaX.
///
/// Connecté au LoginCubit qui gère l'appel API d'inscription.
/// Après inscription réussie → redirige vers /home.
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/login/login_cubit.dart';
import '../../cubits/login/login_state.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Contrôleurs pour récupérer le texte saisi dans chaque champ
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Contrôle la visibilité du mot de passe (œil)
  bool _obscurePassword = true;

  @override
  void dispose() {
    // Libère les contrôleurs pour éviter les fuites mémoire
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      // BlocListener réagit aux changements d'état sans reconstruire l'UI
      listener: (context, state) {
        if (state.loginStatus == LoginStatus.loaded) {
          // Notifie AuthCubit avec le vrai profil
          context.read<AuthCubit>().setAuthenticated(
            UserModel(
              id: state.userId,
              name: state.userName,
              email: _emailController.text.trim(),
            ),
          );
          context.go('/home');
        } else if (state.loginStatus == LoginStatus.error) {
          // Affiche l'erreur dans une SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        // AppBar avec bouton retour vers le login
        appBar: AppBar(
          title: const Text("Créer un compte"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/sign_in'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            // SingleChildScrollView évite l'overflow quand le clavier s'ouvre
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Form(
              key: _formKey, // Associe la clé au formulaire pour la validation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  const Text(
                    "Rejoins NovaX",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Crée ton compte pour commencer à discuter",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 36),

                  // ── Champ Nom complet ──────────────────────────
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nom complet",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    // Validation : champ obligatoire
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Le nom est obligatoire";
                      }
                      if (value.trim().length < 2) {
                        return "Le nom doit contenir au moins 2 caractères";
                      }
                      return null; // null = valide
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Champ Email ────────────────────────────────
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "L'email est obligatoire";
                      }
                      // Vérifie le format email avec une regex simple
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return "Format d'email invalide";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Champ Téléphone (optionnel) ────────────────
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: "Numéro de téléphone (optionnel)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    // Pas de validator : champ optionnel
                  ),
                  const SizedBox(height: 16),

                  // ── Champ Mot de passe ─────────────────────────
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
                      if (value.length < 8) {
                        return "Le mot de passe doit contenir au moins 8 caractères";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Bouton S'inscrire ──────────────────────────
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
                          onPressed: isLoading ? null : _onRegisterPressed,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Créer mon compte",
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Lien vers le login ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Déjà un compte ? "),
                      GestureDetector(
                        onTap: () => context.go('/sign_in'),
                        child: Text(
                          "Se connecter",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // Appelle la vraie méthode register() du LoginCubit
      context.read<LoginCubit>().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
    }
  }
}
