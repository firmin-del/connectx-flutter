/// ============================================================
/// splash_screen.dart
/// Écran de démarrage affiché pendant 3 secondes.
///
/// Rôle principal : vérifier si l'utilisateur est déjà connecté
/// et rediriger vers le bon écran :
///   - Token valide trouvé → /home (liste des conversations)
///   - Pas de token       → /sign_in (écran de login)
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../cubits/login/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Contrôleur d'animation pour le logo (effet fade-in)
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configure l'animation fade-in du logo (0 → 1 en 1 seconde)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Lance l'animation immédiatement
    _animationController.forward();

    // Lance la vérification de session
    _checkAuthAndNavigate();
  }

  /// Vérifie si l'utilisateur est connecté puis navigue.
  Future<void> _checkAuthAndNavigate() async {
    // Attend la durée du splash (3 secondes)
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return; // Sécurité : vérifie que le widget est encore actif

    // Demande au AuthCubit de vérifier le token local
    await context.read<AuthCubit>().checkAuthStatus();

    if (!mounted) return;

    // Lit l'état du AuthCubit pour décider où naviguer
    final authState = context.read<AuthCubit>().state;

    if (authState.status == AuthStatus.authenticated) {
      // Token valide → va directement à la liste des conversations
      context.go('/home');
    } else {
      // Pas de token → va à l'écran de login
      context.go('/sign_in');
    }
  }

  @override
  void dispose() {
    // Libère le contrôleur d'animation pour éviter les fuites mémoire
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        // FadeTransition applique l'animation de fondu au contenu
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application — cercle rouge avec icône play/chat
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded, // Icône [>] du design Kamélia
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),

              // Nom de l'application
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Slogan
              const Text(
                "Messagerie sécurisée & intelligente",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),

              // Indicateur de chargement pendant la vérification du token
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
