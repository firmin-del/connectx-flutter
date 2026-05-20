// profile_screen.dart
// Profil utilisateur avec modification du nom et suppression du compte.

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
        // Bouton modifier le profil
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: "Modifier le profil",
            onPressed: () => _showEditProfileDialog(context, user?.name ?? ''),
          ),
        ],
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
                // Avatar avec animation pop
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    child: Text(
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
                Text(
                  user?.name.isNotEmpty == true ? user!.name : "Utilisateur",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (user?.phoneNumber != null &&
                    user!.phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Paramètres ─────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // Toggle dark/light
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDark = themeMode == ThemeMode.dark;
                    return ListTile(
                      leading: _iconBox(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        AppColors.primary,
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
                  leading: _iconBox(Icons.notifications_outlined, Colors.blue),
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
                  onTap: () => _snack(context, "Bientôt disponible"),
                ),

                const Divider(height: 1, color: AppColors.divider, indent: 16),

                // Confidentialité
                ListTile(
                  leading: _iconBox(Icons.lock_outline, Colors.green),
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
                  onTap: () => _snack(context, "Bientôt disponible"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Actions du compte ──────────────────────────────────
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                // Déconnexion
                ListTile(
                  leading: _iconBox(Icons.logout, AppColors.error),
                  title: const Text(
                    "Se déconnecter",
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),

                const Divider(height: 1, color: AppColors.divider, indent: 16),

                // Supprimer le compte
                ListTile(
                  leading: _iconBox(Icons.delete_forever, Colors.red.shade900),
                  title: Text(
                    "Supprimer mon compte",
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    "Action irréversible",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
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

  // ── Dialogs ───────────────────────────────────────────────────

  /// Dialog pour modifier le nom du profil.
  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Modifier le profil",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: "Nom complet",
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Téléphone (optionnel)",
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              "Annuler",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await context.read<AuthCubit>().updateProfile(
                    name: name,
                    phoneNumber: phone.isEmpty ? null : phone,
                  );
                  if (context.mounted) {
                    _snack(context, "Profil mis à jour ✓");
                  }
                } catch (e) {
                  if (context.mounted) {
                    _snack(context, "Erreur : $e");
                  }
                }
              }
            },
            child: const Text(
              "Enregistrer",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
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
          "Es-tu sûr de vouloir te déconnecter ?",
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

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          "Supprimer le compte",
          style: TextStyle(color: Colors.red.shade700),
        ),
        content: const Text(
          "Cette action est irréversible.\nToutes tes données seront supprimées définitivement.",
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
              try {
                await context.read<AuthCubit>().deleteAccount();
                if (context.mounted) context.go('/sign_in');
              } catch (e) {
                if (context.mounted) _snack(context, "Erreur : $e");
              }
            },
            child: Text(
              "Supprimer",
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
