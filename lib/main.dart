/// ============================================================
/// main.dart
/// Point d'entrée de l'application NovaX.
///
/// Responsabilités :
///   1. Initialiser Hive (base de données locale)
///   2. Configurer les Providers (Repositories + Cubits)
///   3. Configurer le Router (navigation)
///   4. Lancer l'application
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_strategy/url_strategy.dart';

// ── Constantes & Thème ────────────────────────────────────────
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';

// ── Services ──────────────────────────────────────────────────
import 'services/hive_service.dart';

// ── Repositories ──────────────────────────────────────────────
import 'repositories/api_repository/auth_repository.dart';
import 'repositories/message_repository.dart';

// ── Cubits ────────────────────────────────────────────────────
import 'cubits/login/login_cubit.dart';
import 'cubits/login/auth_cubit.dart';
import 'cubits/login/theme_cubit.dart';

// ── Écrans ────────────────────────────────────────────────────
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/profile/profile_screen.dart';

/// Point d'entrée principal de l'application
void main() async {
  // Assure que Flutter est initialisé avant d'appeler des méthodes natives
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive (base de données locale pour les messages offline)
  await HiveService.init();

  // Initialise les formats de dates en français (ex: "lundi 19 mai")
  await initializeDateFormatting('fr_FR', null);

  // URLs propres sur le web (sans le # dans l'URL)
  setPathUrlStrategy();

  // Force l'orientation portrait uniquement (comme WhatsApp)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}

// ── Configuration de la Navigation ────────────────────────────

/// GoRouter définit toutes les routes de l'application.
/// Avantage : navigation déclarative, deep linking, gestion du back button.
final GoRouter router = GoRouter(
  initialLocation: '/', // Démarre toujours par le SplashScreen

  routes: [
    // Splash : vérifie si l'utilisateur est connecté
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // Login : formulaire de connexion
    GoRoute(path: '/sign_in', builder: (context, state) => const LoginScreen()),

    // Register : formulaire d'inscription
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Home : liste des conversations
    GoRoute(path: '/home', builder: (context, state) => const ChatListScreen()),

    // Chat : conversation avec un contact
    // :chatId est un paramètre dynamique (ex: /chat/42)
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        // Récupère l'ID du chat depuis l'URL
        final chatId = state.pathParameters['chatId'] ?? '';
        // Récupère le nom du contact depuis les paramètres de query (optionnel)
        final contactName = state.uri.queryParameters['name'] ?? 'Contact';
        return ChatScreen(chatId: chatId, contactName: contactName);
      },
    ),

    // Profil : page de profil utilisateur
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

// ── Application principale ────────────────────────────────────

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      // ── Repositories ──────────────────────────────────────────
      // Les Repositories sont injectés ici et accessibles dans tout l'arbre
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => MessageRepository()),
      ],

      child: MultiBlocProvider(
        // ── Cubits globaux ────────────────────────────────────────
        // Ces Cubits sont disponibles dans toute l'application
        providers: [
          // ThemeCubit : gère le mode clair/sombre
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),

          // AuthCubit : gère l'état de session global
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),

          // LoginCubit : gère le formulaire de connexion
          BlocProvider<LoginCubit>(
            create: (context) =>
                LoginCubit(authRepository: context.read<AuthRepository>()),
          ),
        ],

        // BlocBuilder écoute le ThemeCubit pour changer le thème dynamiquement
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false, // Cache le bandeau "DEBUG"
              // Thèmes définis dans app_theme.dart
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode, // Contrôlé par ThemeCubit
              // Configuration de la navigation
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
