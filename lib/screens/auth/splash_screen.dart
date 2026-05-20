// splash_screen.dart
// Écran de démarrage — design Kamélia v1.0
//
// Animations :
//   - Logo + texte : fade-in (0 → 1 en 800ms, easeIn)
//   - Titre "NOVAX" : slide-up + fade-in (délai 200ms)
//   - Slogan : fade-in (délai 400ms)
//   - Loader 3 points : apparaît à 600ms, animation pulse infinie
//
// Navigation :
//   - Token valide → /home
//   - Pas de token → /sign_in

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Contrôleurs d'animation ───────────────────────────────────

  // Animation principale : fade-in du logo
  late AnimationController _logoController;
  late Animation<double> _logoFade;

  // Animation du titre : slide-up + fade-in
  late AnimationController _titleController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  // Animation du slogan
  late AnimationController _sloganController;
  late Animation<double> _sloganFade;

  // Animation des 3 points (loader Kamélia)
  late AnimationController _dot1Controller;
  late AnimationController _dot2Controller;
  late AnimationController _dot3Controller;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    // Logo : fade-in en 800ms
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Titre : slide-up + fade-in en 600ms
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3), // Commence 30% plus bas
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    // Slogan : fade-in en 500ms
    _sloganController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sloganFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _sloganController, curve: Curves.easeIn));

    // 3 points animés — chaque point monte/descend en décalé
    // Durée d'un cycle : 1200ms total
    _dot1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dot2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dot3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _startAnimations() async {
    // Logo apparaît immédiatement
    _logoController.forward();

    // Titre apparaît après 200ms
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _titleController.forward();

    // Slogan apparaît après 400ms
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _sloganController.forward();

    // Les 3 points apparaissent après 600ms et s'animent en boucle
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      // Démarre chaque point avec un décalage de 150ms
      _dot1Controller.repeat(reverse: true);
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) _dot2Controller.repeat(reverse: true);
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) _dot3Controller.repeat(reverse: true);
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    await context.read<AuthCubit>().checkAuthStatus();
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    if (authState.status == AuthStatus.authenticated) {
      context.go('/home');
    } else {
      context.go('/sign_in');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _sloganController.dispose();
    _dot1Controller.dispose();
    _dot2Controller.dispose();
    _dot3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo rond rouge [>] ────────────────────────────
            FadeTransition(
              opacity: _logoFade,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Titre NOVAX avec slide-up ──────────────────────
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleFade,
                child: Text(
                  AppConstants.appName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8, // Espacement des lettres comme Kamélia
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Slogan ─────────────────────────────────────────
            FadeTransition(
              opacity: _sloganFade,
              child: const Text(
                "Messagerie sécurisée & intelligente",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 64),

            // ── Loader 3 points animés (design Kamélia) ────────
            FadeTransition(
              opacity: _sloganFade, // Apparaît en même temps que le slogan
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(_dot1Controller),
                  const SizedBox(width: 8),
                  _buildDot(_dot2Controller),
                  const SizedBox(width: 8),
                  _buildDot(_dot3Controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit un point animé qui monte et descend.
  /// [controller] : contrôleur d'animation unique pour ce point.
  Widget _buildDot(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // translateY : le point monte de 0 à -8px et redescend
        final offset = Tween<double>(begin: 0, end: -8).evaluate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        );
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
