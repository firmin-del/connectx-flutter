/// ============================================================
/// theme_cubit.dart
/// Cubit gérant le thème de l'application (clair / sombre).
///
/// Permet à l'utilisateur de basculer manuellement entre
/// le mode clair et le mode sombre, indépendamment du système.
/// Le choix est sauvegardé dans SharedPreferences pour persister
/// entre les sessions.
/// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clé de stockage du thème dans SharedPreferences
const String _themeKey = 'is_dark_mode';

class ThemeCubit extends Cubit<ThemeMode> {
  /// État initial : ThemeMode.dark (design Kamélia = dark mode prioritaire)
  ThemeCubit() : super(ThemeMode.dark) {
    // Charge le thème sauvegardé dès l'instanciation
    _loadSavedTheme();
  }

  // ── Chargement du thème sauvegardé ────────────────────────────

  /// Lit le thème préféré depuis SharedPreferences.
  /// Appelé automatiquement au démarrage.
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupère la valeur sauvegardée (null si première utilisation)
    final isDark = prefs.getBool(_themeKey);

    if (isDark == null) {
      // Première utilisation : suit le thème du système
      emit(ThemeMode.system);
    } else if (isDark) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  // ── Basculement de thème ──────────────────────────────────────

  /// Bascule entre mode clair et mode sombre.
  /// Sauvegarde le choix pour la prochaine session.
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (state == ThemeMode.dark) {
      // Actuellement sombre → passe en clair
      await prefs.setBool(_themeKey, false);
      emit(ThemeMode.light);
    } else {
      // Actuellement clair (ou system) → passe en sombre
      await prefs.setBool(_themeKey, true);
      emit(ThemeMode.dark);
    }
  }

  /// Force le mode clair.
  Future<void> setLight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, false);
    emit(ThemeMode.light);
  }

  /// Force le mode sombre.
  Future<void> setDark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, true);
    emit(ThemeMode.dark);
  }

  // ── Getters utiles ────────────────────────────────────────────

  /// Retourne true si le mode sombre est actif.
  bool get isDarkMode => state == ThemeMode.dark;
}
