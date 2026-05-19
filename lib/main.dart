import 'package:clone_whatsapp_base_code/cubits/login/login_cubit.dart';
import 'package:clone_whatsapp_base_code/repositories/api_repository/auth_repository.dart';
import 'package:clone_whatsapp_base_code/screens/chat/chat_screen.dart';
import 'package:clone_whatsapp_base_code/screens/home/chat_list_screen.dart';
import 'package:clone_whatsapp_base_code/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';

// ===== IMPORTS NOUVEAUX =====
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  setPathUrlStrategy();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(const MainApp());
  });
}

// Configuration GoRouter (on va l'améliorer progressivement)
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/sign_in', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const ChatListScreen()),
 GoRoute(
  path: '/chat/:chatId',
  builder: (context, state) {
    final chatId = state.pathParameters['chatId'] ?? '1';
    return ChatScreen(chatId: chatId);
  },
),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => AuthRepository())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginCubit>(
            create: (context) =>
                LoginCubit(authRepository: context.read<AuthRepository>()),
          ),
          // On ajoutera d'autres Cubits plus tard
        ],
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // Application de notre thème
          theme: AppTheme.lightTheme, // On commence en Light (comme le base)
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // Tu pourras changer en dark plus tard

          routerConfig: router,
        ),
      ),
    );
  }
}
