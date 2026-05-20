// app_colors.dart
// Palette de couleurs officielle NovaX — Design par ABOU Kamélia (UI/UX)
// Wireframes v1.0 — Dark Mode
// Ces couleurs sont utilisées dans app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  // ── Couleurs principales ──────────────────────────────────────
  static const Color primary = Color(
    0xFFB4223F,
  ); // Rouge NovaX (boutons, accents)
  static const Color primaryDark = Color(0xFFE8395A); // Rouge clair (dark mode)

  // ── Fonds ─────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D); // Fond principal dark
  static const Color surface = Color(0xFF1A1A1A); // Cartes, AppBar, inputs

  // ── Bulles de messages ────────────────────────────────────────
  static const Color messageSent = Color(0xFFB4223F); // Mes messages (rouge)
  static const Color messageReceived = Color(
    0xFF2A2A2A,
  ); // Messages reçus (gris foncé)

  // ── Textes ────────────────────────────────────────────────────
  static const Color textPrimary = Color(
    0xFFF0F0F0,
  ); // Texte principal (blanc cassé)
  static const Color textSecondary = Color(
    0xFF9E9E9E,
  ); // Texte secondaire (gris)

  // ── Statuts ───────────────────────────────────────────────────
  static const Color online = Color(0xFF4CAF50); // Point vert "en ligne"
  static const Color error = Color(0xFFCF6679); // Erreurs
  static const Color divider = Color(0xFF2C2C2C); // Séparateurs

  // ── Compatibilité (anciens noms gardés) ───────────────────────
  static const Color success = online;
  static const Color warning = Color(0xFFFFC107);
}
