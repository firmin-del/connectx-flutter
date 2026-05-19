/// ============================================================
/// profile_screen.dart
/// Écran de profil utilisateur.
///
/// Affiche les informations de l'utilisateur connecté et permet :
///   - De voir son nom, email, photo de profil
///   - De basculer entre mode clair et sombre
///   - De se déconnecter
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/login/auth_cubit.dart';
import '../../cubits/login/theme_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupère l'état d'authentification pour afficher les infos utilisateur
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        children: [
          // ── Section Avatar & Nom ───────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            alignment: Alignment.center,
            child: Column(
              children: [
                // Avatar circulaire
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Nom de l'utilisateur
                Text(
                  user?.name.isNotEmpty == true ? user!.name : "Utilisateur",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user?.email ?? "",
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Divider(),

          // ── Section Paramètres ─────────────────────────────────

          // Basculer le thème clair/sombre
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;
              return ListTile(
                leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text("Mode sombre"),
                subtitle: Text(isDark ? "Activé" : "Désactivé"),
                // Switch pour basculer le thème
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                ),
              );
            },
          ),

          // Notifications (placeholder)
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text("Notifications"),
            subtitle: const Text("Gérer les notifications"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Écran de paramètres notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bientôt disponible")),
              );
            },
          ),

          // Confidentialité (placeholder)
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Confidentialité"),
            subtitle: const Text("Chiffrement E2EE activé"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bientôt disponible")),
              );
            },
          ),

          const Divider(),

          // ── Bouton Déconnexion ─────────────────────────────────
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Se déconnecter",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant de déconnecter.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Se déconnecter"),
        content: const Text("Es-tu sûr de vouloir te déconnecter de NovaX ?"),
        actions: [
          // Bouton Annuler
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Annuler"),
          ),
          // Bouton Confirmer
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Déconnecte via AuthCubit (supprime token + déconnecte socket)
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                // Redirige vers le login
                context.go('/sign_in');
              }
            },
            child: const Text(
              "Déconnecter",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
