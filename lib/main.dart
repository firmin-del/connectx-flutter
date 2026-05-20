// main.dart
// Point d'entrée de l'application NovaX.
//
// Ordre d'initialisation (important — chaque étape dépend de la précédente) :
//   1. WidgetsFlutterBinding  → Flutter doit être prêt avant tout
//   2. Firebase.initializeApp → doit être fait avant d'utiliser FCM
//   3. HiveService.init       → ouvre les boîtes de données locales
//   4. NotificationService    → configure les handlers FCM
//   5. runApp                 → lance l'interface

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_strategy/url_strategy.dart';
// Imports Firebase — décommenter quand Firebase sera configuré (flutterfire configure)
// import 'package:firebase_core/firebase_core.dart';

// ── Constantes & Thème ────────────────────────────────────────
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';

// ── Services ──────────────────────────────────────────────────
import 'services/hive_service.dart';
// NotificationService — décommenter quand Firebase sera configuré
// import 'services/notification_service.dart';

// ── Repositories ──────────────────────────────────────────────
import 'repositories/api_repository/auth_repository.dart';
import 'repositories/message_repository.dart';
import 'repositories/chat_repository.dart'; // Ajout Étape 03

// ── Cubits ────────────────────────────────────────────────────
import 'cubits/login/login_cubit.dart';
import 'cubits/login/auth_cubit.dart';
import 'cubits/login/theme_cubit.dart';
import 'cubits/login/chat_cubit.dart'; // Ajout Étape 03

// ── Écrans ────────────────────────────────────────────────────
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/group_info_screen.dart';
import 'models/chat_model.dart'; // Pour GroupInfoScreen extra
import 'screens/profile/profile_screen.dart';
import 'screens/contacts/contacts_screen.dart';
import 'screens/contacts/create_group_screen.dart'; // Nouveau // Ajout Étape 03

void main() async {
  // Étape 1 : Flutter doit être initialisé avant tout appel natif
  WidgetsFlutterBinding.ensureInitialized();

  // Étape 2 : Initialise Firebase (obligatoire avant FCM)
  // Sur le web, Firebase utilise une configuration différente
  // ⚠️  Nécessite google-services.json (Android) ou GoogleService-Info.plist (iOS)
  // ⚠️  Pour activer Firebase : décommenter et configurer avec flutterfire configure
  // try {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   // Étape 3 : Configure les notifications push FCM
  //   await NotificationService.init();
  // } catch (e) {
  //   debugPrint('[Firebase] Non configuré — notifications désactivées: $e');
  // }

  // Étape 3 : Initialise Hive (base de données locale pour les messages offline)
  await HiveService.init();

  // Étape 4 : Initialise les formats de dates en français
  await initializeDateFormatting('fr_FR', null);

  // URLs propres sur le web (sans le # dans l'URL)
  setPathUrlStrategy();

  // Force l'orientation portrait uniquement (comme WhatsApp)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}

// ── Configuration de la Navigation ────────────────────────────

/// GoRouter définit toutes les routes de l'application.
final GoRouter router = GoRouter(
  initialLocation: '/',
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

    // Home : liste des conversations (branché sur ChatCubit)
    GoRoute(path: '/home', builder: (context, state) => const ChatListScreen()),

    // Chat : conversation avec un contact
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId'] ?? '';
        final contactName = state.uri.queryParameters['name'] ?? 'Contact';
        final isGroup = state.uri.queryParameters['group'] == 'true';
        return ChatScreen(
          chatId: chatId,
          contactName: contactName,
          isGroup: isGroup,
        );
      },
    ),

    // Profil : page de profil utilisateur
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Contacts : sélection d'un contact pour démarrer une conversation
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const ContactsScreen(),
    ),

    // Création de groupe
    GoRoute(
      path: '/create-group',
      builder: (context, state) => const CreateGroupScreen(),
    ),

    // Infos du groupe (modifier nom, membres, quitter)
    GoRoute(
      path: '/group-info',
      builder: (context, state) {
        final chat = state.extra as ChatModel?;
        if (chat == null) return const SizedBox.shrink();
        return GroupInfoScreen(chat: chat);
      },
    ),
  ],
);

// ── Application principale ────────────────────────────────────

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      // ── Repositories injectés globalement ─────────────────────
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => MessageRepository()),
        RepositoryProvider(create: (_) => ChatRepository()), // Ajout Étape 03
      ],

      child: MultiBlocProvider(
        // ── Cubits globaux ────────────────────────────────────────
        providers: [
          // ThemeCubit : gère le mode clair/sombre (persisté)
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

          // ChatCubit : gère la liste des conversations (Ajout Étape 03)
          // currentUserId sera mis à jour après le login via AuthCubit
          BlocProvider<ChatCubit>(
            create: (context) => ChatCubit(
              chatRepository: context.read<ChatRepository>(),
              currentUserId: '', // Mis à jour après authentification
            ),
          ),
        ],

        // BlocBuilder écoute ThemeCubit pour changer le thème dynamiquement
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,

              // Thèmes définis dans app_theme.dart
              // Dark mode par défaut selon le design de Kamélia
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode, // Contrôlé par ThemeCubit

              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
