// login_screen.dart
// Écran de connexion — design Kamélia v1.0
//
// Polissage UI :
//   - Effet shake sur le formulaire en cas d'erreur
//   - Animation fade-in du contenu au chargement
//   - Bouton avec spinner pendant la requête API
//   - Champs avec style Kamélia (fond surface, focus rouge)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/login/login_cubit.dart';
import '../../cubits/login/login_state.dart';
import '../../constants/app_constants.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Contrôleur pour l'animation shake sur erreur
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation shake : le formulaire tremble horizontalement sur erreur
    // Durée : 400ms — 4 oscillations rapides
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Tween qui oscille : 0 → 10 → -10 → 10 → -10 → 0
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.loginStatus == LoginStatus.loaded) {
          // Notifie AuthCubit avec le vrai profil utilisateur
          context.read<AuthCubit>().setAuthenticated(
            UserModel(
              id: state.userId,
              name: state.userName,
              email: _emailController.text.trim(),
            ),
          );
          context.go('/home');
        } else if (state.loginStatus == LoginStatus.error) {
          // Déclenche l'animation shake sur erreur
          _shakeController.forward(from: 0);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  // ── Logo rond rouge [>] ────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Titre ─────────────────────────────────────
                  Text(
                    AppConstants.appName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connecte-toi pour continuer",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Formulaire avec effet shake ────────────────
                  // AnimatedBuilder applique le shake sur tout le formulaire
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        // ── Champ Email ──────────────────────────
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "L'email est obligatoire";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Champ Mot de passe ───────────────────
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Bouton SE CONNECTER ────────────────────────
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      final isLoading =
                          state.loginStatus == LoginStatus.loading;

                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : _onLoginPressed,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "SE CONNECTER",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Lien inscription ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pas de compte ? ",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: AppColors.primary,
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

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }
}
