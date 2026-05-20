// app_theme.dart
// Thème visuel NovaX — basé sur les wireframes de ABOU Kamélia (UI/UX v1.0)
// Dark Mode prioritaire selon le design de Kamélia

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── DARK THEME (design principal de Kamélia) ──────────────────
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    // Palette de couleurs
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary, // #B4223F — boutons, accents
      secondary: AppColors.primaryDark, // #E8395A — éléments secondaires
      surface: AppColors.surface, // #1A1A1A — cartes, AppBar
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary, // #F0F0F0
    ),

    // Fond principal
    scaffoldBackgroundColor: AppColors.background, // #0D0D0D
    // AppBar — fond surface, pas d'ombre
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface, // #1A1A1A
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // Typographie — Poppins pour les titres, Inter pour le corps
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          // Titres (AppBar, noms de contacts)
          titleLarge: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          // Corps de texte (messages, aperçus)
          bodyMedium: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          // Texte secondaire (heure, statut)
          bodySmall: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),

    // Champs de saisie (email, mot de passe, message)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),

    // Boutons principaux (SE CONNECTER, CRÉER MON COMPTE)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Fond rouge
        foregroundColor: Colors.white, // Texte blanc
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),

    // Bouton flottant FAB (+)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Séparateurs entre les conversations
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
    ),

    // Switch (mode sombre dans le profil)
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.4);
        }
        return AppColors.surface;
      }),
    ),

    // BottomSheet (menu image_picker)
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // PopupMenu (⋮ dans l'AppBar)
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surface,
      textStyle: TextStyle(color: AppColors.textPrimary),
    ),

    // AlertDialog (confirmation déconnexion)
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: AppColors.textSecondary),
    ),

    // SnackBar (messages d'erreur/succès)
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  // ── LIGHT THEME (optionnel — non prioritaire dans le design Kamélia) ──
  static ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: const Color(0xFFFCFCFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFCFCFC),
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
