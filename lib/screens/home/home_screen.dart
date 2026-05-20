// home_screen.dart
// Écran placeholder — redirige vers ChatListScreen
// Non utilisé dans la navigation principale

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirige automatiquement vers la vraie liste des chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/home');
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
