// profile_screen.dart
// Écran de profil — design Kamélia v1.0
//
// Polissage UI :
//   - Avatar avec animation pop (elasticOut) à l'ouverture
//   - Section header avec fond surface Kamélia
//   - ListTiles avec icônes colorées
//   - Bouton déconnexion rouge

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../cubits/login/theme_cubit.dart';
import '../../theme/app_colors.dart';
import '../../constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Mon Profil",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Section Avatar & Nom ───────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            color: AppColors.surface,
            child: Column(
              children: [
                // Avatar avec animation pop à l'ouverture (elasticOut)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      // Initiales : "Firmin SAMBIENI" → "FS"
                      user != null && user.name.isNotEmpty
                          ? user.name
                                .split(' ')
                                .take(2)
                                .map((e) => e[0].toUpperCase())
                                .join()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nom de l'utilisateur
                Text(
                  user?.name.isNotEmpty == true ? user!.name : "Utilisateur",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user?.email ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Section Paramètres ─────────────────────────────────
          Container(
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label section
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    "PARAMÈTRES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Toggle dark/light mode
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == ThemeMode.dark;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text(
                        "Mode sombre",
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        isDark ? "Activé" : "Désactivé",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Switch(
                        value: isDark,
                        activeColor: AppColors.primary,
                        onChanged: (_) =>
                            context.read<ThemeCubit>().toggleTheme(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1, color: AppColors.divider, indent: 16),

                // Notifications
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    "Notifications",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    "Gérer les notifications",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bientôt disponible")),
                  ),
                ),

                const Divider(height: 1, color: AppColors.divider, indent: 16),

                // Confidentialité
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    "Confidentialité",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    "Chiffrement E2EE activé ✓",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bientôt disponible")),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Bouton Déconnexion ─────────────────────────────────
          Container(
            color: AppColors.surface,
            child: ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              title: const Text(
                "Se déconnecter",
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ),

          const SizedBox(height: 32),

          // ── Version de l'app ───────────────────────────────────
          Center(
            child: Text(
              "NovaX v${AppConstants.appVersion}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Se déconnecter",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          "Es-tu sûr de vouloir te déconnecter de NovaX ?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              "Annuler",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await context.read<AuthCubit>().logout();
              if (context.mounted) context.go('/sign_in');
            },
            child: const Text(
              "Déconnecter",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
